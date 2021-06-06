/*
-- SYS AS SYSDBA
create user mentor
  identified by "some_pwd"
  default tablespace users
  temporary tablespace temp
  profile default
  account unlock;

grant connect to mentor;
grant resource to mentor;
alter user mentor default role all;
alter user mentor quota unlimited on users;
grant create view to mentor;
*/

-- MENTOR AS NORMAL
create or replace type var_type is table of varchar2(10);
/

create sequence seq_mentor_dict_val   start with 5 increment by 5 nocycle cache 20;
/

create sequence seq_mentor_object_val start with 5 increment by 5 nocycle cache 20;
/

-- Справочник сервисов
create table dict_service (
  service_id         number        constraint pk_dict_service primary key,
  name               varchar2(100) constraint nn_dict_service_name not null,
  description        varchar2(4000),
  required_pay_count number        constraint ch_dict_service_required_pay check (required_pay_count >= 0),
  deleted            number(1)     constraint ch_dict_service_deleted check (deleted = 1),
  created_on         date          default sysdate,
  modified_on        date);
comment on table  dict_service                    is 'Справочник сервисов';
comment on column dict_service.service_id         is 'Идентификатор сервиса';
comment on column dict_service.name               is 'Наименование сервиса';
comment on column dict_service.description        is 'Описание сервиса';
comment on column dict_service.required_pay_count is 'Количество первых платежей сервису';
comment on column dict_service.deleted            is 'Признак удаления';
comment on column dict_service.created_on         is 'Дата добавления записи';
comment on column dict_service.modified_on        is 'Дата последнего изменения';

create or replace trigger trig_dict_service_before before insert or update on dict_service for each row
  begin
    if inserting then
      begin
        if :new.service_id is null then
          :new.service_id:=seq_mentor_dict_val.nextval;
        end if;
      end;
     else
      begin
        :new.modified_on:=sysdate;
      end;
    end if;
  end;
/

-- Справочник учеников
create table dict_student (
  student_id        number    constraint pk_dict_student primary key,
  last_name         varchar2(100) constraint nn_dict_student_last_name not null,
  first_name        varchar2(100) constraint nn_dict_student_first_name not null,
  second_name       varchar2(100),
  service_id        number,
  deleted            number(1)    constraint ch_dict_student_deleted check (deleted = 1),
  created_on        date          default sysdate,
  modified_on       date);
comment on table  dict_student                   is 'Справочник учеников';
comment on column dict_student.student_id        is 'Идентификатор ученика';
comment on column dict_student.last_name         is 'Фамилия';
comment on column dict_student.first_name        is 'Имя';
comment on column dict_student.second_name       is 'Отчество';
comment on column dict_student.service_id        is 'Идентификатор сервиса';
comment on column dict_student.deleted           is 'Признак удаления';
comment on column dict_student.created_on        is 'Дата добавления записи';
comment on column dict_student.modified_on       is 'Дата последнего изменения';

alter table dict_student add constraint fk_dict_student_service_id foreign key (service_id) references dict_service (service_id);

create or replace trigger trig_dict_student_before before insert or update on dict_student for each row
  begin
    if inserting then
      begin
        if :new.student_id is null then
          :new.student_id:=seq_mentor_dict_val.nextval;
        end if;
      end;
     else
      begin
        :new.modified_on:=sysdate;
      end;
    end if;
  end;
/

-- Справочник дисциплин
create table dict_discipline (
  discipline_id     number        constraint pk_dict_discipline primary key,
  name              varchar2(100) constraint nn_dict_discipline_name not null,
  deleted           number(1)     constraint ch_dict_discipline_deleted check (deleted = 1),
  created_on        date          default sysdate,
  modified_on       date);
comment on table  dict_discipline                   is 'Справочник дисциплин';
comment on column dict_discipline.discipline_id     is 'Идентификатор дисциплины';
comment on column dict_discipline.name              is 'Наименование дисциплины';
comment on column dict_discipline.deleted           is 'Признак удаления';
comment on column dict_discipline.created_on        is 'Дата добавления записи';
comment on column dict_discipline.modified_on       is 'Дата последнего изменения';

create or replace trigger trig_dict_discipline_before before insert or update on dict_discipline for each row
  begin
    if inserting then
      begin
        :new.discipline_id:=seq_mentor_dict_val.nextval;
      end;
     else
      begin
        :new.modified_on:=sysdate;
      end;
    end if;
  end;
/

-- Справочник курсов
create table dict_course (
  course_id         number      constraint pk_dict_course primary key,
  name              varchar2(100),
  discipline_id     number      constraint nn_dict_course_discipline_id not null,
  cost_value        number      constraint ch_dict_course_cost_value check (cost_value > 0)
                                constraint nn_dict_course_cost_value not null,
  duration          number(3,0) constraint ch_dict_course_duration check (duration > 0)
                                constraint nn_dict_course_duration not null,
  deleted           number(1)   constraint ch_dict_course_deleted check (deleted = 1),
  created_on        date        default sysdate,
  modified_on       date);
comment on table  dict_course                       is 'Справочник курсов';
comment on column dict_course.course_id             is 'Идентификатор курса';
comment on column dict_course.discipline_id         is 'Дисциплина';
comment on column dict_course.name                  is 'Наименование курса';
comment on column dict_course.cost_value            is 'Стоимость одного занятия, руб';
comment on column dict_course.duration              is 'Продолжительность одного занятия, мин';
comment on column dict_course.deleted               is 'Признак удаления';
comment on column dict_course.created_on            is 'Дата добавления записи';
comment on column dict_course.modified_on           is 'Дата последнего изменения';

alter table dict_course add constraint fk_dict_course_discipline_id foreign key (discipline_id) references dict_discipline (discipline_id);

create or replace trigger trig_dict_course_before before insert or update on dict_course for each row
  begin
    if inserting then
      begin
        :new.course_id:=seq_mentor_dict_val.nextval;
      end;
     else
      begin
        :new.modified_on:=sysdate;
      end;
    end if;
  end;
/

-- Связи учеников с курсами
create table student_course_pty (
  student_id number,
  course_id  number,
  constraint pk_student_course_pty primary key (student_id, course_id));
comment on table  student_course_pty            is 'Связи учеников с курсами';
comment on column student_course_pty.student_id is 'Идентификатор студента';
comment on column student_course_pty.course_id  is 'Идентификатор курса';

-- Расписание занятий
create table mentor_schedule(
  mentor_schedule_id number    constraint pk_mentor_schedule primary key,
  course_id          number    constraint nn_mentor_schedule_course not null,
  student_id         number    constraint nn_mentor_schedule_student not null,
  begin_date         date,
  end_date           date,
  state              number(1) constraint ch_mentor_schedule_state check (state = 1),
  deleted            number(1) constraint ch_mentor_schedule_deleted check (deleted = 1),
  created_on         date      default sysdate,
  modified_on        date);

comment on table  mentor_schedule                    is 'Расписание занятий';
comment on column mentor_schedule.mentor_schedule_id is 'Идентификатор занятия';
comment on column mentor_schedule.course_id          is 'Идентификатор курса';
comment on column mentor_schedule.begin_date         is 'Дата и время начала занятия';
comment on column mentor_schedule.end_date           is 'Дата и время окончания занятия';
comment on column mentor_schedule.state              is 'Статус занятия (null - запланировано; 1 - состоялось)';
comment on column mentor_schedule.deleted            is 'Признак удаления';
comment on column mentor_schedule.created_on         is 'Дата добавления записи';
comment on column mentor_schedule.modified_on        is 'Дата последнего изменения';

alter table mentor_schedule add constraint fk_mentor_schedule_course_id foreign key (course_id) references dict_course (course_id);
alter table mentor_schedule add constraint fk_mentor_schedule_student_id foreign key (student_id) references dict_student (student_id);

create or replace trigger trig_mentor_schedule_before before insert or update on mentor_schedule for each row
  begin
    if inserting then
      begin
        :new.mentor_schedule_id:=seq_mentor_object_val.nextval;
      end;
     else
      begin
        :new.modified_on:=sysdate;
      end;
    end if;
  end;
/

-- Платежи
create table mentor_payment (
  mentor_payment_id  number    constraint pk_mentor_payment primary key,
  mentor_schedule_id number    constraint nn_mentor_payment_sched_id not null,
  pay_value          number,
  service_value      number,
  tax_value          number,
  income_value       number,
  processed          number(1) constraint ch_mentor_payment_processed check (processed = 1),
  processed_on       date,
  created_on         date      default sysdate,
  modified_on        date);

comment on table  mentor_payment                    is 'Платежи';
comment on column mentor_payment.mentor_payment_id  is 'Идентификатор платежа';
comment on column mentor_payment.mentor_schedule_id is 'Идентификатор занятия';
comment on column mentor_payment.pay_value          is 'Сумма платежа, руб';
comment on column mentor_payment.service_value      is 'Плата сервису, руб';
comment on column mentor_payment.tax_value          is 'Налог, руб';
comment on column mentor_payment.income_value       is 'Доход, руб';
comment on column mentor_payment.processed          is 'Статус обработки платежа (1 - платеж обработан)';
comment on column mentor_payment.processed_on       is 'Дата обработки платежа';
comment on column mentor_payment.created_on         is 'Дата добавления записи';
comment on column mentor_payment.modified_on        is 'Дата последнего изменения';

alter table mentor_payment add constraint fk_mentor_payment_schedule_id foreign key (mentor_schedule_id) references mentor_schedule (mentor_schedule_id);

create or replace trigger trig_mentor_payment_before before insert or update on mentor_payment for each row
  begin
    if inserting then
      begin
        :new.mentor_payment_id:=seq_mentor_object_val.nextval;
      end;
     else
      begin
        :new.modified_on:=sysdate;
      end;
    end if;
  end;
/