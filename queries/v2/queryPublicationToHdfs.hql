USE ${source_db};
INSERT OVERWRITE DIRECTORY '${destination_path}'
SELECT p.id as id, p.pid as pid, p.title as title, p.description as description, p.subject as subject, p.publisher as publisher,
p.bestaccessright as bestaccessright, p.language as language, p.journal as journal,p.fulltext as fulltext, p.published as published,
p.authors as authors,
pub_org.organizations as organizations,
pub_pr.projects as projects
FROM
(
SELECT
pub.id as id, pub.pid.value as pid, pub.title.value as title, collect_list(named_struct('name', vId.fullname, 'pid', vId.pid.value)) as authors,
pub.description.value as description, pub.subject.value as subject, pub.bestaccessright.classname as bestaccessright, pub.language.classname as language,
pub.journal.name as journal, pub.fulltext.value as fulltext,pub.instance.dateofacceptance.value as published,pub.publisher.value as publisher
FROM publication pub LATERAL VIEW explode(pub.author) visitor AS vId
GROUP BY id,pid,title,description,subject,bestaccessright,language,journal,fulltext,instance, publisher
) p
LEFT OUTER JOIN (
SELECT pubs.id as id, collect_set(named_struct('title',proj.title.value, 'id', proj.id, 'code', proj.code.value)) AS projects
FROM publication pubs LEFT OUTER JOIN relation r_proj_s ON r_proj_s.source = pubs.id LEFT OUTER JOIN project proj ON r_proj_s.target = proj.id
WHERE r_proj_s.reltype = 'resultProject' GROUP BY pubs.id) pub_pr ON p.id = pub_pr.id
LEFT OUTER JOIN (
SELECT pubs.id as id, collect_set(named_struct('name', org.legalname.value,'short', org.legalshortname.value, 'id', org.id)) AS organizations
FROM publication pubs LEFT OUTER JOIN relation r_org_s ON r_org_s.source = pubs.id LEFT OUTER JOIN organization org ON r_org_s.target = org.id
WHERE r_org_s.reltype = 'resultOrganization' GROUP BY pubs.id ) pub_org ON p.id = pub_org.id;
