USE ${source_db};
INSERT OVERWRITE DIRECTORY '${destination_path}'
SELECT sw_q.id as id, sw_q.pid as pid, sw_q.title as title, sw_q.description as description, sw_q.subject as subject, sw_q.publisher as publisher,
sw_q.bestaccessright as bestaccessright, sw_q.language as language,sw_q.fulltext as fulltext, sw_q.published as published,
sw_q.authors as authors,
sw_org.organizations as organizations,
sw_pr.projects as projects
FROM
(
SELECT
sw.id as id, sw.pid.value as pid, sw.title.value as title, collect_list(named_struct('name', vId.fullname, 'pid', vId.pid.value)) as authors,
sw.description.value as description, sw.subject.value as subject, sw.bestaccessright.classname as bestaccessright, sw.language.classname as language,
sw.fulltext.value as fulltext, sw.instance.dateofacceptance.value as published, sw.publisher.value as publisher
FROM software sw LATERAL VIEW explode(sw.author) visitor AS vId
GROUP BY id,pid,title,description,subject,bestaccessright,language,fulltext,instance, publisher
) sw_q
LEFT OUTER JOIN (
SELECT sw.id as id, collect_set(named_struct('name', org.legalname.value,'short', org.legalshortname.value, 'id', org.id)) AS organizations
FROM software sw LEFT OUTER JOIN relation r_org_s ON r_org_s.source = sw.id LEFT OUTER JOIN organization org ON r_org_s.target = org.id
WHERE r_org_s.reltype = 'resultOrganization' GROUP BY sw.id) sw_org ON sw_q.id = sw_org.id
LEFT OUTER JOIN (
SELECT sw.id as id,collect_set(named_struct('title',proj.title.value, 'id', proj.id, 'code', proj.code.value)) AS projects
FROM software sw LEFT OUTER JOIN relation r_proj_s ON r_proj_s.source = sw.id LEFT OUTER JOIN project proj ON r_proj_s.target = proj.id
WHERE r_proj_s.reltype = 'resultProject' GROUP BY sw.id) sw_pr ON sw_q.id = sw_pr.id;
