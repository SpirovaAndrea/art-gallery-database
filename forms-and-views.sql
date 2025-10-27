--FORMS

insert into artist(artistid, galleryadminid, artistname, password, portfoliolink, 
countryoforigin)  
values  
(103, 'GA2', 'Andy Warhol', 'warhol', 'www.andywarhol.com', 'Pittsburgh, 
Pennsylvania'); 

select * from artist;
 
insert into arttype(typeid, typename)  
values  
(3434, 'Pop Art'); 

insert into artwork (artworkid, artistid, galleryadminid, typeid, email_buyer, title, price, 
description)  
values  
(005, 103, 'GA3', 3434, 'stacy.grace@icloud.com', '10 Marilyns, 1982', '4500', 'Made 
with Offset Lithograph, hand signed in pencil'); 

insert into review (reviewid, artworkid, email_buyer, feedback, rating)  
values  
(5, 005, 'stacy.grace@icloud.com', 'Obsessed with celebrity, consumer culture, and 
mechanical reproduction', 3); 

insert into showcased(exhibitionid, artworkid)  
values  
(202, 005); 
select * from showcased;

-- VIEWS
-- VIEW 1: EXHIBITIONS PAGE
CREATE OR REPLACE VIEW view_exhibitions_page AS
SELECT
    e.exhibitionid,
    TRIM(e.exhtitle) as exhibition_title,
    e.startdate,
    e.enddate,
    TRIM(ga.email) as admin_email,
    TRIM(ga.responsibilities) as admin_role,
    COUNT(DISTINCT s.artworkid) as total_artworks,
    COUNT(DISTINCT p.artistid) as participating_artists
FROM exhibition e
LEFT JOIN galleryadmin ga ON e.galleryadminid = ga.galleryadminid
LEFT JOIN showcased s ON e.exhibitionid = s.exhibitionid
LEFT JOIN participates p ON e.exhibitionid = p.exhibitionid
GROUP BY e.exhibitionid, e.exhtitle, e.startdate, e.enddate, ga.email, ga.responsibilities
ORDER BY e.startdate DESC;


-- VIEW 2: ARTWORKS IN EACH EXHIBITION
CREATE OR REPLACE VIEW view_exhibition_artworks AS
SELECT
    e.exhibitionid,
    TRIM(e.exhtitle) as exhibition_title,
    a.artworkid,
    TRIM(a.title) as artwork_title,
    a.price,
    TRIM(a.description) as description,
    TRIM(art.artistname) as artist_name,
    TRIM(at.typename) as art_type,
    CASE
        WHEN a.email_buyer IS NOT NULL THEN 'Sold'
        ELSE 'Available'
    END as availability
FROM exhibition e
JOIN showcased s ON e.exhibitionid = s.exhibitionid
JOIN artwork a ON s.artworkid = a.artworkid
JOIN artist art ON a.artistid = art.artistid
JOIN arttype at ON a.typeid = at.typeid
ORDER BY e.exhibitionid, a.artworkid;


-- VIEW 3: ARTISTS PAGE
CREATE OR REPLACE VIEW view_artists_page AS
SELECT
    a.artistid,
    TRIM(a.artistname) as artist_name,
    TRIM(a.portfoliolink) as portfolio_link,
    TRIM(a.countryoforigin) as country,
    STRING_AGG(TRIM(p.phonenumber), ', ') as phone_numbers,
    COUNT(DISTINCT aw.artworkid) as total_artworks,
    COUNT(DISTINCT ex.exhibitionid) as exhibitions_participated
FROM artist a
LEFT JOIN phonenumber p ON a.artistid = p.artistid
LEFT JOIN artwork aw ON a.artistid = aw.artistid
LEFT JOIN participates part ON a.artistid = part.artistid
LEFT JOIN exhibition ex ON part.exhibitionid = ex.exhibitionid
GROUP BY a.artistid, a.artistname, a.portfoliolink, a.countryoforigin
ORDER BY a.artistname;


-- VIEW 4: ARTIST ARTWORKS
CREATE OR REPLACE VIEW view_artist_artworks AS
SELECT
    art.artistid,
    TRIM(art.artistname) as artist_name,
    a.artworkid,
    TRIM(a.title) as artwork_title,
    a.price,
    TRIM(a.description) as description,
    TRIM(at.typename) as art_type,
    CASE
        WHEN a.email_buyer IS NOT NULL THEN 'Sold'
        ELSE 'Available'
    END as availability
FROM artist art
JOIN artwork a ON art.artistid = a.artistid
JOIN arttype at ON a.typeid = at.typeid
ORDER BY art.artistid, a.artworkid;


-- VIEW 5: ARTWORK FULL DETAILS PAGE
CREATE OR REPLACE VIEW view_artwork_details AS
SELECT
    a.artworkid,
    TRIM(a.title) as artwork_title,
    a.price,
    TRIM(a.description) as description,
    TRIM(at.typename) as art_type,
    at.typeid,
    art.artistid,
    TRIM(art.artistname) as artist_name,
    TRIM(art.portfoliolink) as artist_portfolio,
    TRIM(art.countryoforigin) as artist_country,
    STRING_AGG(DISTINCT TRIM(pn.phonenumber), ', ') as artist_phones,
    CASE
        WHEN a.email_buyer IS NOT NULL THEN 'Sold'
        ELSE 'Available'
    END as availability,
    TRIM(b.username) as purchased_by,
    STRING_AGG(DISTINCT TRIM(e.exhtitle), ', ') as showcased_in_exhibitions
FROM artwork a
JOIN arttype at ON a.typeid = at.typeid
JOIN artist art ON a.artistid = art.artistid
LEFT JOIN buyer b ON a.email_buyer = b.email
LEFT JOIN showcased s ON a.artworkid = s.artworkid
LEFT JOIN exhibition e ON s.exhibitionid = e.exhibitionid
LEFT JOIN phonenumber pn ON art.artistid = pn.artistid
GROUP BY a.artworkid, a.title, a.price, a.description, at.typename, at.typeid,
         art.artistid, art.artistname, art.portfoliolink, art.countryoforigin,
         a.email_buyer, b.username;


-- VIEW 6: ARTWORK REVIEWS
CREATE OR REPLACE VIEW view_artwork_reviews AS
SELECT
    r.reviewid,
    r.artworkid,
    TRIM(a.title) as artwork_title,
    TRIM(r.feedback) as feedback,
    r.rating,
    TRIM(b.username) as reviewer_name,
    TRIM(b.email) as reviewer_email
FROM review r
JOIN artwork a ON r.artworkid = a.artworkid
JOIN buyer b ON r.email_buyer = b.email
ORDER BY r.artworkid, r.rating DESC;


-- VIEW 7: ALL AVAILABLE ARTWORKS
CREATE OR REPLACE VIEW view_available_artworks AS
SELECT
    a.artworkid,
    TRIM(a.title) as artwork_title,
    a.price,
    TRIM(a.description) as description,
    TRIM(at.typename) as art_type,
    TRIM(art.artistname) as artist_name,
    art.artistid
FROM artwork a
JOIN arttype at ON a.typeid = at.typeid
JOIN artist art ON a.artistid = art.artistid
WHERE a.email_buyer IS NULL  -- Only available artworks
ORDER BY a.artworkid;


-- VIEW 8: BUYER PURCHASE HISTORY
CREATE OR REPLACE VIEW view_buyer_purchases AS
SELECT
    TRIM(b.email) as buyer_email,
    TRIM(b.username) as buyer_name,
    a.artworkid,
    TRIM(a.title) as artwork_title,
    a.price,
    TRIM(art.artistname) as artist_name,
    TRIM(at.typename) as art_type
FROM buyer b
JOIN artwork a ON b.email = a.email_buyer
JOIN artist art ON a.artistid = art.artistid
JOIN arttype at ON a.typeid = at.typeid
ORDER BY b.email, a.artworkid;


SELECT * FROM view_artwork_details;

-- Update view_exhibition_artworks_full to include image_url
CREATE VIEW view_exhibition_artworks_full AS
SELECT
    s.exhibitionid,
    a.artworkid,
    TRIM(a.title) as artwork_title,
    a.price,
    TRIM(a.description) as description,
    TRIM(at.typename) as art_type,
    art.artistid,
    TRIM(art.artistname) as artist_name,
    TRIM(art.countryoforigin) as artist_country,
    a.image_url,
    CASE
        WHEN a.email_buyer IS NOT NULL THEN 'Sold'
        ELSE 'Available'
    END as availability
FROM showcased s
JOIN artwork a ON s.artworkid = a.artworkid
JOIN artist art ON a.artistid = art.artistid
JOIN arttype at ON a.typeid = at.typeid
ORDER BY s.exhibitionid, a.artworkid;

-- Update view_artwork_details to include image_url
DROP VIEW IF EXISTS view_artwork_details CASCADE;
CREATE VIEW view_artwork_details AS
SELECT
    a.artworkid,
    TRIM(a.title) as artwork_title,
    a.price,
    TRIM(a.description) as description,
    TRIM(at.typename) as art_type,
    at.typeid,
    art.artistid,
    TRIM(art.artistname) as artist_name,
    TRIM(art.portfoliolink) as artist_portfolio,
    TRIM(art.countryoforigin) as artist_country,
    STRING_AGG(DISTINCT TRIM(pn.phonenumber), ', ') as artist_phones,
    a.image_url,
    CASE
        WHEN a.email_buyer IS NOT NULL THEN 'Sold'
        ELSE 'Available'
    END as availability,
    TRIM(b.username) as purchased_by,
    STRING_AGG(DISTINCT TRIM(e.exhtitle), ', ') as showcased_in_exhibitions
FROM artwork a
JOIN arttype at ON a.typeid = at.typeid
JOIN artist art ON a.artistid = art.artistid
LEFT JOIN buyer b ON a.email_buyer = b.email
LEFT JOIN showcased s ON a.artworkid = s.artworkid
LEFT JOIN exhibition e ON s.exhibitionid = e.exhibitionid
LEFT JOIN phonenumber pn ON art.artistid = pn.artistid
GROUP BY a.artworkid, a.title, a.price, a.description, at.typename, at.typeid,
         art.artistid, art.artistname, art.portfoliolink, art.countryoforigin,
         a.email_buyer, b.username, a.image_url;

SELECT artworkid, artwork_title, image_url FROM view_exhibition_artworks_full;
SELECT artworkid, artwork_title, image_url FROM view_artwork_details;