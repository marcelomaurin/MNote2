create table selproduct(
   idproduto INTEGER PRIMARY KEY  AUTOINCREMENT null,
   productDesc char(20) not null,
   productDetail char(40) ,
   Detail01 char(20),
   Detail02 char(20),
   price char(20)     
);


insert into selproduct (productDesc, productDetail, Detail01, Detail02, price) 
values ('Test','Test Detail ', 'Test Detail01','Test Detail02','R$1,70');
