--- slow one:
CREATE TEMPORARY TABLE qq1 AS SELECT user_article AS user_article_id FROM user_article_tag WHERE tag = 5819;
ALTER TABLE qq1 ADD INDEX user_article_id_idx (user_article_id);
CREATE TEMPORARY TABLE qq2 AS SELECT uas.user_article_id FROM qq1 AS uas NATURAL JOIN user_article uao WHERE ((((uao.private = 0 AND uao.private_gang IS NULL) OR uao.private_gang IN ('4','22') OR (uao.private_until IS NOT NULL AND uao.private_until <= NOW())) AND uao.quarantined IS NULL) OR uao.user = '978') AND uao.user_article_id IS NOT NULL ORDER BY uao.created DESC LIMIT 0, 1000;
ALTER TABLE qq2 ADD INDEX user_article_id_idx (user_article_id);
SELECT   ua.user_article_id,
         COUNT(DISTINCT ua2.user_article_id) as _ua_user_articles_count,
         COUNT(DISTINCT c2.comment_id) as _ua_comments_count,
         COUNT(DISTINCT ua3.user_article_id) as _ua_article_is_linked_by_current_user,
         COUNT(DISTINCT t4.tag_id) as _ua_is_geotagged,
         ua.user, ua.article, ua.bookmark, ua.updated, ua.citation, ua.user_is_author,
         ua.def_public, ua.private, ua.private_gang, ua.private_until, ua.quarantined, ua.created,
         u.user_id, u.username, u.openurl_resolver, u.openurl_name, u.updated,
         IFNULL(GROUP_CONCAT(DISTINCT CONCAT(g.gang_id),':/:',IFNULL(g.name, '+NULL'),':/:',IFNULL(g.owner, '+NULL'),':/:',IFNULL(g.private, '+NULL'),':/:',IFNULL(g.updated, '+NULL') ORDER BY ug.created SEPARATOR '///'), '') AS _u_gangs_packed,
         a.article_id, a.hash, a.citation, a.created, a.updated,
         b.bookmark_id, b.url, b.hash, b.article, b.citation, b.first_user, b.created, b.updated,
         bd.bookmark_id, bd.created,
         ct.citation_id, ct.journal, ct.volume, ct.issue, ct.start_page, ct.end_page, ct.pubmed,
         ct.doi, ct.asin, ct.ris_type, ct.raw_date, ct.date, ct.last_modified_date, ct.user_supplied, ct.cs_module,
         ct.cs_type, ct.cs_source, ct.cs_score, ct.created,
         j.journal_id, j.name, j.issn, j.coden, j.country, j.medline_code, j.medline_ta, j.nlm_unique_id,
         IFNULL(GROUP_CONCAT(DISTINCT CONCAT(au.author_id),':/:',IFNULL(au.firstname, '+NULL'),':/:',IFNULL(au.forename, '+NULL'),':/:',IFNULL(au.initials, '+NULL'),':/:',IFNULL(au.middlename, '+NULL'),':/:',IFNULL(au.lastname, '+NULL'),':/:',IFNULL(au.suffix, '+NULL'),':/:',IFNULL(au.misc, '+NULL'),':/:',IFNULL(au.postal_address, '+NULL'),':/:',IFNULL(au.affiliation, '+NULL'),':/:',IFNULL(au.email, '+NULL'),':/:',IFNULL(au.user, '+NULL') ORDER BY cta.displayorder SEPARATOR '///'), '') AS _ct_authors_packed,
         ct2.citation_id, ct2.journal, ct2.volume, ct2.issue, ct2.start_page, ct2.end_page, ct2.pubmed,
         ct2.doi, ct2.asin, ct2.ris_type, ct2.raw_date, ct2.date, ct2.last_modified_date, ct2.user_supplied,
         ct2.cs_module, ct2.cs_type, ct2.cs_source, ct2.cs_score, ct2.created,
         j2.journal_id, j2.name, j2.issn, j2.coden, j2.country, j2.medline_code, j2.medline_ta, j2.nlm_unique_id,
         IFNULL(GROUP_CONCAT(DISTINCT CONCAT(au2.author_id),':/:',IFNULL(au2.firstname, '+NULL'),':/:',IFNULL(au2.forename, '+NULL'),':/:',IFNULL(au2.initials, '+NULL'),':/:',IFNULL(au2.middlename, '+NULL'),':/:',IFNULL(au2.lastname, '+NULL'),':/:',IFNULL(au2.suffix, '+NULL'),':/:',IFNULL(au2.misc, '+NULL'),':/:',IFNULL(au2.postal_address, '+NULL'),':/:',IFNULL(au2.affiliation, '+NULL'),':/:',IFNULL(au2.email, '+NULL'),':/:',IFNULL(au2.user, '+NULL') ORDER BY cta2.displayorder SEPARATOR '///'), '') AS _ct2_authors_packed,
         ct3.citation_id, ct3.journal, ct3.volume, ct3.issue, ct3.start_page, ct3.end_page, ct3.pubmed,
         ct3.doi, ct3.asin, ct3.ris_type, ct3.raw_date, ct3.date, ct3.last_modified_date, ct3.user_supplied,
         ct3.cs_module, ct3.cs_type, ct3.cs_source, ct3.cs_score, ct3.created,
         j.journal_id, j.name, j.issn, j.coden, j.country, j.medline_code, j.medline_ta, j.nlm_unique_id,
         IFNULL(GROUP_CONCAT(DISTINCT CONCAT(au3.author_id),':/:',IFNULL(au3.firstname, '+NULL'),':/:',IFNULL(au3.forename, '+NULL'),':/:',IFNULL(au3.initials, '+NULL'),':/:',IFNULL(au3.middlename, '+NULL'),':/:',IFNULL(au3.lastname, '+NULL'),':/:',IFNULL(au3.suffix, '+NULL'),':/:',IFNULL(au3.misc, '+NULL'),':/:',IFNULL(au3.postal_address, '+NULL'),':/:',IFNULL(au3.affiliation, '+NULL'),':/:',IFNULL(au3.email, '+NULL'),':/:',IFNULL(au3.user, '+NULL') ORDER BY cta3.displayorder SEPARATOR '///'), '') AS _ct3_authors_packed,
         IFNULL(GROUP_CONCAT(DISTINCT CONCAT(t2.tag_id),':/:',IFNULL(t2.name, '+NULL') ORDER BY uat2.created SEPARATOR '///'), '') AS _ua_tags_packed
FROM qq2 AS uap
LEFT JOIN user_article ua ON (uap.user_article_id=ua.user_article_id)
LEFT JOIN user u ON (ua.user=u.user_id)
LEFT JOIN user_article_tag uat2 ON (ua.user_article_id=uat2.user_article)
LEFT JOIN tag t2 ON (uat2.tag=t2.tag_id)
LEFT JOIN user_article_details uad ON (ua.user_article_id=uad.user_article_id)
LEFT JOIN citation ct ON (ua.citation=ct.citation_id)
LEFT JOIN citation_author cta ON (ct.citation_id=cta.citation)
LEFT JOIN author au ON (cta.author=au.author_id)
LEFT JOIN journal j ON (ct.journal=j.journal_id)
LEFT JOIN article a ON (ua.article=a.article_id)
LEFT JOIN bookmark b ON (ua.bookmark=b.bookmark_id)
LEFT JOIN bookmark_details bd ON (b.bookmark_id=bd.bookmark_id)
LEFT JOIN citation ct2 ON (a.citation=ct2.citation_id)
LEFT JOIN citation_author cta2 ON (ct2.citation_id=cta2.citation)
LEFT JOIN author au2 ON (cta2.author=au2.author_id)
LEFT JOIN journal j2 ON (ct2.journal=j2.journal_id)
LEFT JOIN citation ct3 ON (b.citation=ct3.citation_id)
LEFT JOIN citation_author cta3 ON (ct3.citation_id=cta3.citation)
LEFT JOIN author au3 ON (cta3.author=au3.author_id)
LEFT JOIN journal j3 ON (ct3.journal=j3.journal_id)
LEFT JOIN user_gang ug ON (u.user_id=ug.user)
LEFT JOIN gang g ON (ug.gang=g.gang_id)
LEFT JOIN article a2 ON (ua.article=a2.article_id)
LEFT JOIN user_article ua2 ON (a2.article_id=ua2.article AND ((((ua2.private = 0 AND ua2.private_gang IS NULL) OR ua2.private_gang IN ('4','22') OR (ua2.private_until IS NOT NULL AND ua2.private_until <= NOW())) AND ua2.quarantined IS NULL) OR ua2.user = '978'))
LEFT JOIN user_article_comment uac2 ON (ua2.user_article_id=uac2.user_article)
LEFT JOIN comment c2 ON (uac2.comment=c2.comment_id)
LEFT JOIN user_article ua3 ON (uac2.user_article=ua3.user_article_id AND ua3.user = '978')
LEFT JOIN user_article_tag uat4 ON (ua.user_article_id=uat4.user_article)
LEFT JOIN tag t4 ON (uat4.tag=t4.tag_id AND t4.name = 'geotagged')
WHERE ua.user_article_id IS NOT NULL
GROUP BY uap.user_article_id
ORDER BY uap.user_article_id DESC;
DROP TEMPORARY TABLE qq1;
DROP TEMPORARY TABLE qq2;
