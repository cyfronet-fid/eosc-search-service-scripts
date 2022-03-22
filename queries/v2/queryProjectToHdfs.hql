USE ${source_db};
INSERT OVERWRITE DIRECTORY '${destination_path}'
SELECT
proj.id as id,
proj.pid.value as pid,
proj.acronym.value as acronym,
proj.code.value as code,
proj.keywords.value as keywords,
proj.title.value as title,
proj.summary.value as summary,
proj.startdate.value as startdate,
proj.enddate.value as enddate,
proj.duration.value as duration,
proj.ecsc39.value as clause39,
collect_set(named_struct('name', org.legalname.value,'short', org.legalshortname.value, 'id', org.id)) AS organizations
FROM project proj
LEFT OUTER JOIN relation r_proj_s ON r_proj_s.source = proj.id
LEFT OUTER JOIN organization org ON r_proj_s.target = org.id
WHERE r_proj_s.reltype = "projectOrganization"
GROUP BY proj.id,proj.pid,proj.acronym,proj.code,proj.keywords,proj.title,proj.summary,proj.startdate,proj.enddate,proj.duration,proj.ecsc39;
