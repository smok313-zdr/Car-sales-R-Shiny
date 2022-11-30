use cars;

-- create table sale_2018 (brand varchar(255), model varchar(255), amountSold int NOT NULL);

/*
insert into sale_2018 values("Skoda","Octavia",21125),("Skoda","Fabia",19679),("Opel","Astra",15282),
("Volkswagen","Golf",14190),("Toyota","Yaris",14032),("Toyota","Auris",12073),("Ford","Focus",11126),
("Dacia","Duster",9844),("Skoda","Rapid",9833),("Volkswagen","Passat",9192),("Nissan","Qashqai",8537),
("Renault","Clio",8353),("Hyundai","Tuscon",8065),("Fiat","Tipo",8059),("Skoda","Superb",8045),
("Toyota","Corolla",7509),("Toyota","C-HR",7355),("Volkswagen","Tiguan",6847),("Dacia","Sandero",6446),
("Opel","Corsa",6127),("Kia","Sportage",6082),("SEAT","Leon",6038),("Kia","Ceed",5838),
("Renault","Megane",5533),("Volkswagen","Polo",5358),("Toyota","RAV4",4892),("Ford","Fiesta",4442),
("Hyundai","i20",4390),("Volvo","XC60",4353),("Toyota","Aygo",4308);
*/ 

select count(*),brand from sale_2018 group by brand
