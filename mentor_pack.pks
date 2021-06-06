create or replace package mentor_pack is

-- Сервисы 
procedure insert_service(
  p_name               in varchar2,
  p_description        in varchar2 default null,
  p_required_pay_count in number);

procedure update_service(
  p_name               in varchar2,
  p_description        in varchar2,
  p_required_pay_count in number,
  p_service_id         in number);
  
procedure delete_service(
  p_service_id         in number);

-- Ученики
procedure insert_student(
  p_last_name          in varchar2,
  p_first_name         in varchar2,
  p_second_name        in varchar2,
  p_service_id         in number default null);
  
procedure update_student(
  p_last_name          in varchar2,
  p_first_name         in varchar2,
  p_second_name        in varchar2,
  p_student_id         in number);

procedure delete_student(
  p_student_id         in number);
  
-- Дисциплины
procedure insert_discipline(
  p_name               in varchar2);
  
procedure update_discipline(
  p_name               in varchar2,
  p_discipline_id      in number);
  
procedure delete_discipline(
  p_discipline_id      in number);

-- Курсы
procedure insert_course(
  p_name               in varchar2,
  p_discipline_id      in number,
  p_cost_value         in number,
  p_duration           in number);
  
procedure update_course(
  p_name               in varchar2,
  p_discipline_id      in number,
  p_cost_value         in number,
  p_duration           in number,
  p_course_id          in number);
  
procedure delete_course(
  p_course_id          in number);
  
-- Привязки
function string_to_table(
  p_list               in varchar2,
  p_split              in varchar2) return var_type;
  
procedure init_student_course_pty(
  p_student_id         in number,
  p_course_str         in varchar2,
  p_split              in varchar2);
  
-- Расписание
-- функция проверки наличия пересечения в расписании (1 - присутствует пересечение; 0 - отсутствует пересечение)
function check_crossing(
  p_course_id          in number,
  p_begin_date         in date,
  p_end_date           in date,
  p_mentor_schedule_id in number) return number;

-- добавление занятия в расписание
procedure insert_mentor_schedule(
  p_course_id          in number,
  p_student_id         in number,
  p_begin_date         in date,
  p_end_date           in date);
  
-- редактирование записи расписания
procedure update_mentor_schedule(
  p_course_id          in number,
  p_student_id         in number,
  p_begin_date         in date,
  p_end_date           in date,
  p_mentor_schedule_id in number);

-- удаление записи расписания
procedure update_mentor_schedule(
  p_mentor_schedule_id in number);

-- планировщик занятий
procedure init_mentor_schedule(
  p_begin_date         in date,
  p_day_count          in number);

-- утверждение занятия расписания
procedure approve_mentor_schedule_row(
  p_mentor_schedule_id in number);

-- групповое утверждение занятий расписания
procedure approve_mentor_schedule;
  
end;