USE ${source_db};
INSERT OVERWRITE DIRECTORY '${destination_path}'
SELECT orp_q.id as id, orp_q.pid as pid, orp_q.title as title, orp_q.description as description, orp_q.subject as subject, orp_q.publisher as publisher,
orp_q.bestaccessright as bestaccessright, orp_q.language as language,orp_q.fulltext as fulltext, orp_q.published as published,
orp_q.authors as authors,
orp_org.organizations as organizations,
orp_pr.projects as projects
FROM
(
SELECT
orp_s.id as id, orp_s.pid.value as pid, orp_s.title.value as title, collect_list(named_struct('name', vId.fullname, 'pid', vId.pid.value)) as authors,
orp_s.description.value as description, orp_s.subject.value as subject, orp_s.bestaccessright.classname as bestaccessright, orp_s.language.classname as language,
orp_s.fulltext.value as fulltext, orp_s.instance.dateofacceptance.value as published, orp_s.publisher.value as publisher
FROM otherresearchproduct orp_s LATERAL VIEW explode(orp_s.author) visitor AS vId
GROUP BY id,pid,title,description,subject,bestaccessright,language,fulltext,instance, publisher
) orp_q
LEFT OUTER JOIN (
SELECT orp.id as id, collect_set(named_struct('name', org.legalname.value,'short', org.legalshortname.value, 'id', org.id)) AS organizations
FROM otherresearchproduct orp LEFT OUTER JOIN relation r_org_s ON r_org_s.source = orp.id LEFT OUTER JOIN organization org ON r_org_s.target = org.id
WHERE r_org_s.reltype = 'resultOrganization' GROUP BY orp.id) orp_org ON orp_q.id = orp_org.id
LEFT OUTER JOIN (
SELECT orp.id as id, collect_set(named_struct('title',proj.title.value, 'id', proj.id, 'code', proj.code.value)) AS projects
FROM otherresearchproduct orp LEFT OUTER JOIN relation r_proj_s ON r_proj_s.source = orp.id LEFT OUTER JOIN project proj ON r_proj_s.target = proj.id
WHERE r_proj_s.reltype = 'resultProject' GROUP BY orp.id) orp_pr ON orp_q.id = orp_pr.id;
