-- Mise à jour des affiliations à partir des références connues
UPDATE affiliation
SET
    city = CASE id
        WHEN 353 THEN 'Stanford, CA'
        WHEN 365 THEN 'Pasadena, CA'
        WHEN 366 THEN 'Cambridge, MA'
    END,

    country = CASE id
        WHEN 353 THEN 'USA'
        WHEN 365 THEN 'USA'
        WHEN 366 THEN 'USA'
    END,

    city_inferred = 1,

    country_inferred = CASE
        WHEN country IS NULL THEN 1
        ELSE 0
    END

WHERE id IN (353, 365, 366);

-- Cas de l'affiliation Howard Hughes Medical Institute
UPDATE affiliation
SET needs_review = 1
WHERE id = 357;

-- Cas des affiliations non visibles dans les self-join
UPDATE affiliation
SET needs_review = 1
WHERE city IS NULL
  AND id NOT IN (353, 365, 366);
