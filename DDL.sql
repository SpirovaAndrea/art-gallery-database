
create table ArtType(
typeid integer,
typename varchar(50) not null,
constraint pk_arttype primary key (typeid)
);

insert into arttype (typeid, typename) values
(8879, 'Painting, Aquarelle'),
(6533, 'Street Poster Art'),
(4311, 'Light Instalation');

create table GalleryAdmin(
galleryadminid char(20),
email char(50) not null,
password varchar(30) not null,
responsibilities varchar(150) not null,
lastlogindate timestamp not null,
constraint pk_galleryadmin primary key (galleryadminid)
);

insert into galleryadmin (galleryadminid, email, password, responsibilities, lastlogindate)
values
('GA1', 'dance.balvan@hotmail.com', 'dance123*', 'Organize and oversee exhibitions',
'2023-12-05 20:15:00'::timestamp),
('GA2', 'simona.koleva@live.com', 'simikoleva', 'Manage artists and their verification',
'2023-12-12 09:00:00'::timestamp),
('GA3', 'marija.trajkovska@gmail.com', 'mari2000', 'Artwork approvals and submissions',
'2023-12-10 10:30:00'::timestamp); --Buyer (Email, UserName, Password, PaymentDetails)

create table Buyer(
email char(50),
username char(30) not null,
password varchar(30) not null,
paymentdetails varchar(100) not null,
constraint pk_buyer primary key (email)
);

insert into buyer (email, username,password,paymentdetails) values
('isidorija@yahoo.com', 'Isidorija', 'isi1995', 'Credit Card ending in 7548'),
('stacy.grace@icloud.com', 'Stacy123', 'stacegrace', 'Paypal'),
('aleksandra_milososka@gmail.com', 'AlexMil', 'alex369', 'Credit Card ending in 7623'); --Exhibition (ExhibitionID, ExhTitle, StartDate, EndDate, GalleryAdminID*(GalleryAdmin))

create table Exhibition(
exhibitionid integer,
galleryadminid char(20),
exhtitle char(30) not null,
startdate timestamp not null,
enddate timestamp not null,
constraint pk_exhibition primary key (exhibitionid),
constraint fk_exhibition_galleryad foreign key (galleryadminid) references
galleryadmin(galleryadminid)
);

insert into exhibition (exhibitionid, galleryadminid, exhtitle, startdate, enddate) values
(200, 'GA1', 'Енергии во просторот', '2023-12-24 14:00:00'::timestamp , '2023-12-26
20:00:00'::timestamp),
(201, 'GA1', 'Bending Light II', '2024-2-1 09:30:00'::timestamp , '2024-2-2
15:00:00'::timestamp),
(202, 'GA1', 'Visual Dialogues', '2023-12-15 20:00:00'::timestamp , '2023-12-15
22:00:00'::timestamp); --Artist (ArtistID, ArtistName, PortfolioLink, CountryOfOrigin, GalleryAdminID*(GalleryAdmin))

create table Artist(
artistid integer,
galleryadminid char(20),
password varchar(30) not null,
artistname char(30) not null,
portfoliolink char(50) not null,
countryoforigin varchar(50) not null,
constraint pk_artist primary key (artistid),
constraint fk_artist_galleryad foreign key (galleryadminid) references
galleryadmin(galleryadminid)
);

insert into artist (artistid, galleryadminid, artistname, password, portfoliolink, countryoforigin)
values
(100, 'GA2', 'Keith Haring', 'haring', 'www.haring.com' , 'Pennsylvania, U.S.'),
(101, 'GA2', 'James Turrell', 'turrell', 'www.jamesturrell.com', 'California, U.S.'),
(102, 'GA2', 'Vasko Taskovski', 'taskovski', 'www.taskovski.com', 'North Macedonia'); --Artwork (ArtworkID, Title, Price, Description, ArtistID*(Artist), ExhibitionID*(Exhibition),

create table Artwork(
artworkid integer,
artistid integer,
galleryadminid char(20),
typeid integer,
email_buyer char(50),
title char(30) not null,
price integer not null,
description varchar(150) not null,
constraint pk_artwork primary key (artworkid),
constraint fk_artwork_artist foreign key (artistid) references artist(artistid),
constraint fk_artwork_galleryad foreign key (galleryadminid) references
galleryadmin(galleryadminid),
constraint fk_artwork_arttype foreign key (typeid) references arttype(typeid),
constraint fk_artwork_buyer foreign key (email_buyer) references buyer(email)
);

insert into artwork (artworkid, artistid, galleryadminid, typeid, email_buyer, title, price,
description) values
(001, 102, 'GA3', 8879, 'isidorija@yahoo.com', 'Раѓање на градот, 1997','1500',
'Aquarelle painting inspired by the revolution of his hometown'),
(002, 101, 'GA3', 4311, 'stacy.grace@icloud.com', 'Beneath the Surface, 2021', '32000',
'LED light, etched glass and shallow space, 52-inch diameter'),
(003, 101, 'GA3', 4311, 'aleksandra_milososka@gmail.com', 'From Aten Reign, 2016',
'65000', 'Ukiyo-e Japanese style woodcut with relief printing - 66cm × 47cm'),
(004, 100, 'GA3', 6533, 'aleksandra_milososka@gmail.com', 'Ignorance = Fear', '2000',
'Poster, political activism and raising awareness'); --Review (ReviewID, Feedback, Rating, ArtworkID*(Artwork), BuyerID*(Buyer))

create table Review(
reviewid integer,
artworkid integer,
email_buyer char(50),
feedback varchar(150) not null,
rating integer check (rating between 1 and 5),
constraint pk_review primary key (reviewid),
constraint fk_review_artwork foreign key (artworkid) references artwork(artworkid),
constraint fk_review_buyer foreign key (email_buyer) references buyer(email)
);

insert into review (reviewid, artworkid, email_buyer, feedback, rating) values
(1, 001, 'isidorija@yahoo.com', 'Еден од најнадарените македонски академски
сликари и водечки претставник на надреализмот!!', 5),
(2, 002, 'stacy.grace@icloud.com', 'I look up to see if there will be a James Turrell
installation wherever I go', 5),
(3, 003, 'aleksandra_milososka@gmail.com', 'Light is the perfect word for the art of
James Turrell.', 4),
(4, 004, 'aleksandra_milososka@gmail.com', 'One poster can produce a thousand
thoughts...', 5); --PhoneNumber (ArtistID*(Artist), PhoneNumber)

create table PhoneNumber(
artistid integer,
phonenumber varchar(20),
constraint pk_phonenumber primary key (artistid,phonenumber),
constraint fk_phonenumber_artist foreign key (artistid) references artist(artistid)
);

insert into phonenumber (artistid, phonenumber) values
(100, '(570)555-1234'),
(101, '(510)123-7890'),
(102, '+38972223305');

create table participates(
artistid integer,
exhibitionid integer,
constraint pk_participates primary key (artistid,exhibitionid),
constraint fk_participates_artist foreign key (artistid) references artist(artistid),
constraint fk_participates_exhibition foreign key (exhibitionid) references
exhibition(exhibitionid)
);
insert into participates (artistid, exhibitionid) values
(100, 202),
(101, 201),
(101, 202),
(102, 200);

create table attends(
exhibitionid integer,
email_buyer char(50),
constraint pk_attends primary key (exhibitionid, email_buyer),
constraint fk_attends_exhibition foreign key (exhibitionid) references
exhibition(exhibitionid),
constraint fk_attends_buyer foreign key (email_buyer) references buyer(email)
);
insert into attends (exhibitionid, email_buyer) values
(200, 'isidorija@yahoo.com'),
(202, 'aleksandra_milososka@gmail.com'),
(202, 'stacy.grace@icloud.com'),
(201, 'aleksandra_milososka@gmail.com'); --showcased (ExhibitionID*(Exhibition), ArtworkID*(Artwork))

create table showcased(
exhibitionid integer,
artworkid integer,
constraint pk_showcased primary key (exhibitionid, artworkid),
constraint fk_showcased_exhibition foreign key (exhibitionid) references
exhibition(exhibitionid),
constraint fk_showcased_artwork foreign key (artworkid) references
artwork(artworkid)
);
insert into showcased (exhibitionid, artworkid) values
(200, 001),
(201, 002),
(201, 003),
(202, 004),
(202, 002);

ALTER TABLE artwork ADD COLUMN image_url VARCHAR(255);


UPDATE artwork SET image_url = 'taskovski.jpg' WHERE artworkid = 1;
UPDATE artwork SET image_url = 'turrell1.png' WHERE artworkid = 2;
UPDATE artwork SET image_url = 'turrell2.jpg' WHERE artworkid = 3;
UPDATE artwork SET image_url = 'haring.png' WHERE artworkid = 4;

