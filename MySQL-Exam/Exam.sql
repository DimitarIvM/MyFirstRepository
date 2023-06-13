create database universities_db;

use universities_db;

create table countries (
id int primary key auto_increment,
name varchar(40) not null unique
);

create table cities (
id int primary key auto_increment,
name varchar (40) not null unique,
population int, 
country_id int not null,
FOREIGN KEY (country_id) references countries(id)
);

create table universities (
id int primary key AUTO_INCREMENT,
name varchar (60) not null unique,
address varchar (80) not null unique,
tuition_fee decimal(19,2) not null,
number_of_staff int,
city_id int,
FOREIGN KEY (city_id) references cities (id) 

);

create table students (
id int primary key AUTO_INCREMENT,
first_name varchar (40) not null,
last_name varchar(40) not null,
age int,
phone varchar(20) not null unique,
email varchar (255) not null unique,
is_graduated tinyint(1) not null,
city_id int, 
foreign key (city_id) REFERENCES cities(id) 
);

create table courses (
id int primary key AUTO_INCREMENT,
name varchar (40) not null unique,
duration_hours decimal (19,2),
start_date DATE ,
teacher_name varchar (60) not null unique,
description text,
university_id int,
foreign key (university_id) references universities(id)
);

create table students_courses (
grade decimal(19,2) not null,
student_id int not null,
course_id int not null,
foreign key (student_id) references students (id),
FOREIGN KEY (course_id) references courses (id)
);

select* from courses
where id <=5;


-- --2
insert into courses  (name, duration_hours,start_date,teacher_name, `description`,university_id)
select  concat(c.teacher_name, ' ','course'), 
 length(c.name) /10,
 date_add(c.start_date, INTERVAL 5 DAY),
 reverse(c.teacher_name),
 concat('Course', ' ',c.teacher_name, reverse(c.description)), 
 day(start_date)
from courses c
where id<=5; 

select * from courses where id<=5; 


-- 3
update universities
set tuition_fee = tuition_fee+300
where id between 5 and 12;
-- 4
delete u from universities u
where u.number_of_staff is null;


-- 5 

select * from cities
order by population desc;

-- 6 

select first_name, last_name, age, phone, email 
from students 
where age >=21
order by first_name desc, email, id
limit 10;

-- 7 

SELECT concat(s.first_name,' ',s.last_name), substring(s.email,2,10) as username, reverse(s.phone) as `password`
from students as s
left join students_courses as sc on s.id = sc.student_id
where sc.student_id is null 
order by `password` DESC ;

-- 8

select count(s.id) as students_count, u.name as university_name
from  universities as u
 join courses as c on u.id = c.university_id
 join students_courses as sc on sc.course_id = c.id
 join students as s on sc.student_id = s.id
GROUP BY u.name
having students_count >=8 
order by students_count desc,u.name desc;

select *
from  universities as u
join cities as c on u.city_id = c.id
join students as s on s.city_id = c.id;
-- GROUP BY university_name
-- having students_count >=8 
-- order by students_count desc,u.name desc;


-- 9 

select u.name,c.name,u.address, 
if (u.tuition_fee < 800, 'cheap', 
if(u.tuition_fee between 800 and 1200,'normal',
if (u.tuition_fee between 1200 and 2500,'high','expensive'
)
)
) as 'price_rank',
u.tuition_fee
from universities as u
join cities as c on u.city_id = c.id
order by tuition_fee;

-- 10 
DELIMITER $$
create function udf_average_alumni_grade_by_course_name (course_name VARCHAR(60)) 
returns DEcimal (3,2)
DETERMINISTIC
begin 
declare `avg` decimal(3,2);
 set `avg`:=(
select  AVG (sc.grade ) from 
students as s 
join students_courses as sc on s.id = sc.student_id
join courses as c on sc.course_id = c.id
where c.name = course_name and s.is_graduated = 1
group by c.name);
return `avg`;
end $$ 
DELIMITER ;

SELECT c.name, udf_average_alumni_grade_by_course_name('Quantum Physics') as average_alumni_grade FROM courses c 
WHERE c.name = 'Quantum Physics';


-- 11 
DELIMITER $$
CREATE PROCEDURE udp_graduate_all_students_by_year (`year_started` INT)
BEGIN
    UPDATE students s
       join students_courses as sc on s.id = sc.student_id
join courses as c on sc.course_id = c.id

    SET is_graduated = 1
    WHERE YEAR (c.start_date) = year_started;
END $$
DELIMITER ;

CALL udp_reduce_price('Phones and tablets');

select s.first_name, is_graduated,c.start_date
from students as s 
join students_courses as sc on s.id = sc.student_id
join courses as c on sc.course_id = c.id;

