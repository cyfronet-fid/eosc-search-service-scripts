USE ${source_db};
INSERT OVERWRITE DIRECTORY '${destination_path}'
SELECT
o.id as id,
o.pid.value as pid,
o.legalname.value as legalname,
o.legalshortname.value as legalshortname,
o.country as country,
o.alternativenames.value as alternativenames,
o_pr.projects AS projects
from organization o
LEFT OUTER JOIN (
SELECT org.id as id,collect_set(named_struct('title',proj.title.value, 'id', proj.id, 'code', proj.code.value)) AS projects
FROM organization org LEFT OUTER JOIN relation r_org_s ON r_org_s.source = org.id LEFT OUTER JOIN project proj ON r_org_s.target = proj.id
WHERE r_org_s.reltype = 'projectOrganization' GROUP BY org.id) o_pr ON o_pr.id = o.id;
