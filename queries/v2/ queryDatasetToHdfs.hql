USE ${source_db};
INSERT OVERWRITE DIRECTORY '${destination_path}'
SELECT ds_q.id as id, ds_q.pid as pid, ds_q.title as title, ds_q.description as description, ds_q.subject as subject, ds_q.publisher as publisher,
ds_q.bestaccessright as bestaccessright, ds_q.language as language,ds_q.fulltext as fulltext, ds_q.published as published,
ds_q.authors as authors,
ds_org.organizations as organizations,
ds_pr.projects as projects
FROM
(
SELECT
ds_s.id as id, ds_s.pid.value as pid, ds_s.title.value as title, collect_list(named_struct('name', vId.fullname, 'pid', vId.pid.value)) as authors,
ds_s.description.value as description, ds_s.subject.value as subject, ds_s.bestaccessright.classname as bestaccessright, ds_s.language.classname as language,
ds_s.fulltext.value as fulltext, ds_s.instance.dateofacceptance.value as published, ds_s.publisher.value as publisher
FROM dataset ds_s LATERAL VIEW explode(ds_s.author) visitor AS vId
GROUP BY id,pid,title,description,subject,bestaccessright,language,fulltext,instance, publisher
) ds_q
LEFT OUTER JOIN (
SELECT ds.id as id, collect_set(named_struct('name', org.legalname.value,'short', org.legalshortname.value, 'id', org.id)) AS organizations
FROM dataset ds LEFT OUTER JOIN relation r_org_s ON r_org_s.source = ds.id LEFT OUTER JOIN organization org ON r_org_s.target = org.id
WHERE r_org_s.reltype = 'resultOrganization' GROUP BY ds.id) ds_org ON ds_q.id = ds_org.id
LEFT OUTER JOIN(
SELECT ds.id as id, collect_set(named_struct('title',proj.title.value, 'id', proj.id, 'code', proj.code.value)) AS projects
FROM dataset ds LEFT OUTER JOIN relation r_proj_s ON r_proj_s.source = ds.id LEFT OUTER JOIN project proj ON r_proj_s.target = proj.id
WHERE r_proj_s.reltype = 'resultProject' GROUP BY ds.id) ds_pr ON ds_q.id = ds_pr.id;
