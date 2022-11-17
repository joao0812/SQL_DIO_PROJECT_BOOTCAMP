create schema if not exists company;
use company; 

# Restrição atribuida a um domínio
# create domain D_num as int check(Dnum > 0 and Dnum<21);

# TABELAS
create table if not exists employee(
	Fname varchar(15) NOT NULL,
    Mname varchar(15) NOT NULL,
    Lname varchar(15) NOT NULL,
    Ssn char(9) NOT NULL, # Char indica q temos q ter 9 digitos, é um valor constante, não podemos ter menos tal qual no Varchar 
    Bdate DATE,
    Address varchar(30),
    Sex char,
    Salary decimal(10,2),
    Super_ssn char(9),
    Dnum int NOT NULL,
    constraint chk_salary_employee check (Salary>2000.0),
    constraint pk_employee primary key (Ssn)
);

create table if not exists departament(
	Dname varchar(15) NOT NULL, 
    Dnum int NOT NULL,
    Mgr_ssn char(9),
    Mgr_start_date DATE, 
    Dept_creat_date DATE,
    primary key (Dnum),
    Unique (Dname),
    foreign key (Mgr_ssn) references employee(Ssn)
);

create table if not exists dept_locations(
	Dnum int NOT NULL, 
    Dlocation varchar(15) NOT NULL,
    constraint pk_dept_locations primary key (Dnum, Dlocation),
    constraint fk_dept_locations foreign key (Dnum) references departament(Dnum)
);

create table if not exists project(
	Pname varchar(15) NOT NULL,
    Pnum int NOT NULL, 
    Plocation varchar(15),
    Dnum int NOT NULL,
    primary key (Pnum),
    constraint unique_project UNIQUE (Pname), # Um nome seja associado a apenas um projeto
    constraint fk_project foreign key (Dnum) references departament(Dnum)
);

create table if not exists works_on(
	Essn char(9) NOT NULL,
    Pnum int NOT NULL, 
    Hours decimal(3,1) NOT NULL,
    primary key (Essn, Pnum),
    constraint fk_employee_works_on foreign key (Essn) references employee(Ssn),
    constraint fk_project_works_on foreign key (Pnum) references project(Pnum)
);

create table if not exists dependent (
	Essn char(9) NOT NULL,
    Dependent_name varchar(15) NOT NULL,
    Sex char, 
    Bdate DATE,
    Relationship varchar(8),
    Age int NOT NULL, 
    constraint chk_age_dependent check(Age<21),
    primary key (Essn, Dependent_name),
    constraint fk_dependent foreign key (Essn) references employee(Ssn)
);



# drop table dependent;
show tables;
select * from dependent; # Mostra os valores q a Tabela tem, os atributos/coluna da mesma
select * from information_schema.columns where TABLE_NAME = 'dependent'; # Como ver todos as colunas de uma determinada tabela
# desc dependent;

# ALTER TABLE departament ADD Dept_creat_date DATE

select * from information_schema.table_constraints where constraint_schema = 'company';
# select * from information_schema.referential_constraints where constraint_schema = 'company'

select Ssn, Fname, Dname from employee e, departament d where(e.Ssn = d.Mgr_ssn); # Retorna o gerente e seu departamento

select Ssn, Fname, Dependent_name from employee, dependent where Essn = Ssn; # Retorna uma tabela q mostra o employee e seus respectivos dependentes, e o tipo desse dependente se é filho, filha, subrinho, marido e etc

select Bdate, Address from employee where Fname = 'John' and Minit='B' and Lname='Smith'; # Retorna o Bdate e o endereço do employee q tem o Fname, Minit e Lname iguais os registrados nesse código


select Fname, Lname, Address from employee, departament where Dname='Research' and Dnum=Dnum; # Retorna os employee q trabalham no departament de nome (Dname) Research

# Operações em SQL
select Fname, Lname, Salary, Salary*0.011 from employee; # cria uma coluna Salary*0,011 onde os valores são o resultado da mult entre o valor de Salarry e 0,011
select Fname, Lname, Salary, Salary*0.011 as INSS from employee; # Cria a mesma coluna acima mas com o nome de INSS e com os mesmos valores

select concat(Fname, ' ', Lname) as complete_name, Salary, round(Salary*1.1, 2) as increased_salary 
	from employee e, works_on as w, project as p
    where (e.Ssn = w.Essn and w.Pnum = p.Pnum and p.Pname = 'ProductX');
    
# Definindo aliuas para legibilidade da consulta
select concat(e.Fname, ' ', e.Lname) as Employee_Name, e.Adress from employee e, departamente d where d.Dname = 'Research' and d.Dnum = e.Dnum;


# Recuperando informações dos departamentos presentes em Stafford
select Dname as Departamente_Name, Mgr_ssn as Manager, Address from departament d, dept_locations l, employee e
	where d.Dnum = l.Dnum and Dlocarion = 'Stafford';
    
# Recuperando todos os gerentes que trabalham em Stafford
select Dname as Departamente_Name, Mgr_ssn as Manager, Address from departament d, dept_locations l, employee e
	where d.Dnum = l.Dnum and Dlocarion = 'Stafford' and Mgr_ssn = e.Ssn;

# Like e Between
select * from employee;

select concat(Fname, ' ', Lname) Complete_Name, Dname as Departament_Name from emplyee e, departament d
	where (e.Ssn = d.Essn and e.Dnum = d.Dnum and Address like '%Houston%');

select concat(Fname, ' ', Lname) Complete_Name, Address from employee
	where (Address like '%Houston%');
    
    
select fname, Lname from employee where (Salary > 30000 and Salary < 40000);
select fname, Lname from employee where (Salary between 30000 and 40000); # resume a escrite do de cima, retorna a qunatidade de tuplas/linhas baseados nesse range de 30000 à 40000


# Operadores Lógicos

select Bdate, Address from employee where Fname ='John' and Lname = 'Smith';

select * from departament where dname='research' or Dname ='Administration';

select Fname, Lname from employee e, departament d where Dname ='Researc' and e.Dnum = d.Dnum;


# Unior, except e intersect OBS: só funcionam entre tabelas de mesma quantidade de parametros -> A é um elemento da tabela R e S
# Except -> not in
select * from S where A not in (select A from R);
# Union
(select distinct R.A from R) UNION (select distinct S.A from S); # Funciona sem o distinct por conta q o UNION o conjunto retornado já é sem redundância
# Intersect -> in
select distinct R.A from R where R.A in (select S.A from S);


# Subqueries
select distinct Pnum from project 
	where Pnum in
		(select distinct Pnum from works_on, employee where Essn=Ssn and Lname='Smith') 
        or
		(select Pnum from project p, departament d, employee e where Mgr_ssn = Ssn and Lname='Smith' and p.Dnum =d.Dnum);
        
select distinct Essn from works_on
	where (Pnum, Hours) IN (select Pnum, Hours from works_on where Essn = 'Um valor válido q já ta na tabela Hours');



# Quais employee possuem dependentes ?
select e.Fname, e.Lname from employee as e
	where exists (select * from dependent as d 
						where e.Ssn = d.Essn and Relationship='Son'); # Essa última condição retorna quem tem filho menino
                        
# Quais employee NÃO possuem dependentes ?
select e.Fname, e.Lname from employee as e
	where not exists (select * from dependent as d 
						where e.Ssn = d.Essn); 


select e.Fname, e.Lname from employee as e, departament d
	where (e.Ssn=d.Mgr_ssn) and exists (select * from dependent as d where e.Ssn = d.Essn); 		
                        
# Cláusulas de ordenação

select * from employee order by Fname; # Ordena com base no First Name, retorna a tabela em ordem alfabética baseada nos dados (nome) de Fname

# Retorna todos os valores de employee, departament, works_on e projects q atendem a condição do WHERE de forma ordenada crescente com base na condição do ORDER BY - Esses valores não se repetem devido ao distinct
select distinct * from departament as d, employee as e, works_on as w, projects as p
	where (d.Dnum = e.Dnum and e.Ssn=d.Mgr_ssn and w.Pnum=p.Pnum)
    order by d.Dname, e.Fname, e.Lname;


# Funções e cláusulas de agrupamento
select * from employee;

select count(*) from employee;

select count(*) from employee e, departament d
	where e.Dnum=d.Dnum and d.Dname='Research';
    
select d.Dnum, count(*) as Numver_of_employee, round(avg(salary),2) as Salary_avg from employee
	group by Dnum;
    
select Pnum, Pname, count(*) from projects p, works_on w
	where p.Pnum = w.Pnum 
    group by p.Pnum, p.Pname;
    
select count(distinct Salary) from employee;
select sum(Salary) as Total_sal, max(Salary) as Total_sal, min(Salary) as min_sal, avg(Salary) as Avg_sal from employee;
                        
select Pnum, Pname, count(*) from project p, works_on
	where p.Pnum = w.Pnum
    group by p.Pnum, p.Pname;
    
select Pnum, Pname, count(*) from project p, works_on 
	where p.Pnum = w.Pnum
	group by p.Pnum, p.Pname
    having count(*) > 2;
    
select Dnum, count(*) from employee
	where Salary > 30000
	group by Dnum
    having count(*) > 2;
    
#
select Dnum, count(*) from employee
	where Salary>20000 and Dnum in (select Dnum from employee
									group by Dnum
									having count(*)>2)
    group by Dnum;
    

# Case Statement 
# SafeMode Problem: Edit -> Preferences -> SQL Editor -> desable Safe updates -> Restart the MySQL WorkBench
update employee set Salary = 
	case 
		when Dnum=5 then Salary+2000
        when Dnum=3 then Salary+1500
        when Dnum=1 then Salary+3000
        else Salary+0
    end;

    
# Join Statment
select e.fname, e.lname, d.Dname FROM emnployee e JOIN departament e ON e.dept_id = d.dept_id;			

desc employee;
desc works_on;

# JOIN

select * from employee, works_on where Ssn = Essn;
select * from employee JOIN works_on ON Ssn = Essn;

# JOIN ON -> INNER JOIN ON

# Recupera o Fname, Lname e o Address de um employee q esta no departamento Research
select Fname, Lname, Address from (employee e JOIN departamente d ON e.Dnum=d.Dnum) where Dname='Research';
select Dname, Dept_create_date, Dlocation from departament JOIN dept_location using(Dnumver) order by Dept_create_date;

# CROSS JOIN - Produto cartesiano

select * from employee CROSS JOIN dependent;


# JOIN com mais de 3 tabelas

# project, works_on e employee -- Revisar nas aulas ou os dados das tabelas do banco de dados 
select * from employee e
	INNER JOIN works_on w ON Ssn = Essn
	INNER JOIN project p ON w.Dnum = p.Dnum
    WHERE p.Plocation LIKE 'S%' # Todos as localizações que começam com S
    ORDER BY Pnum;



# OUTER JOIN

select * from employee;
select * from dependent;

select * from employee inner join dependent on Ssn = Essn;
select * from employee LEFT JOIN dependent on Ssn = Essn;
select * from employee LEFT OUTER JOIN dependent on Ssn = Essn;







                        
                        


#show databases;
#create database if not exists first_example;
#use first_example;
#CREATE TABLE if not exists person(
#	person_id smallint unsigned,
#	fname varchar(20),
#	lname varchar(20),
#	gender enum('M', 'F', 'Others'),
#	Bdate date,
#	street varchar(30),
#	city varchar(20),
#	state varchar(20),
#	country varchar(20),
#	postal_code varchar(30),
#   constraint pk_person primary key (person_id)
#);
#show tables;
#desc person;

#CREATE TABLE if not exists favorite_food(
#	person_id smallint unsigned,
#    food varchar(20),
#    constraint pk_favorite_food primary key (person_id, food),
#    constraint fk_favorite_food_person_id foreign key(person_id) references person(person_id)    
#);

#desc favorite_food;
#SELECT * from information_schema.table_constraints WHERE constraint_schema = 'first_example';

#desc person;

#insert into person value ('2', 'Brenda', 'Silva', 'F', '1979-08-21', 'rua tal', 'Rio de Janeiro', 'RJ', 'Brasil', '26054-89'),
#						('3', 'Ana', 'Maria', 'F', '1979-08-21', 'rua tal', 'Rio de Janeiro', 'RJ', 'Brasil', '26054-89'),
#                        ('4', 'Carolina', 'Rocha', 'F', '1979-08-21', 'rua tal', 'Rio de Janeiro', 'RJ', 'Brasil', '26054-89');
#SELECT * from person;

#desc favorite_food;
#INSERT into favorite_food value(1, 'Lasanha');
#select * from favorite_food;

#delete from person where person_id=2 
#						or person_id=3 
#                        or person_id=4;