create or replace package body mentor_pack is

procedure insert_service(
  p_name               in varchar2,
  p_description        in varchar2 default null,
  p_required_pay_count in number)
  is
  begin
    insert into dict_service (
      name,
      description,
      required_pay_count)
    values (
      p_name,
      p_description,
      p_required_pay_count);
    commit;
    exception when others then raise_application_error(-20001, sqlerrm);
  end;
  
procedure update_service(
  p_name               in varchar2,
  p_description        in varchar2,
  p_required_pay_count in number,
  p_service_id         in number) is
  begin
    update dict_service
    set    name               = p_name,
           description        = p_description,
           required_pay_count = p_required_pay_count
    where  service_id         = p_service_id;
    commit;
    exception when others then raise_application_error(-20001, sqlerrm);
  end;
  
procedure delete_service(
  p_service_id         in number) is
  begin
    update dict_service
    set    deleted = 1
    where  service_id = p_service_id;
    commit;
    exception when others then raise_application_error(-20001, sqlerrm);
  end;

procedure insert_student(
  p_last_name          in varchar2,
  p_first_name         in varchar2,
  p_second_name        in varchar2,
  p_service_id         in number default null)
  is
  begin
    insert into dict_student (
      last_name,
      first_name,
      second_name,
      service_id)
    values (
      p_last_name,
      p_first_name,
      p_second_name,
      p_service_id);
    commit;
    exception when others then
    begin
      rollback;
      raise_application_error(-20001, sqlerrm);
    end;
  end;
  
procedure update_student(
  p_last_name          in varchar2,
  p_first_name         in varchar2,
  p_second_name        in varchar2,
  p_student_id         in number) is
  begin
    update dict_student
    set    last_name   = p_last_name,
           first_name  = p_first_name,
           second_name = p_second_name
    where  student_id  = p_student_id;
    commit;
    exception when others then raise_application_error(-20001, sqlerrm);
  end;
  
procedure delete_student(
  p_student_id         in number) is
  begin
    -- пометка занятий в расписании к удалению
    update mentor_schedule
    set    deleted = 1
    where  student_id = p_student_id;
    -- пометка ученика к удалению
    update dict_student
    set    deleted = 1
    where  student_id = p_student_id;
    commit;
    exception when others then
    begin
      rollback;
      raise_application_error(-20001, sqlerrm);
    end;
  end;
  
procedure insert_discipline(
  p_name              in varchar2) is
  begin
    insert into dict_discipline (
      name)
    values (
      p_name);
    commit;
    exception when others then raise_application_error(-20001, sqlerrm);
  end;
  
procedure update_discipline(
  p_name              in varchar2,
  p_discipline_id     in number) is
  begin
    update dict_discipline
    set    name          = p_name
    where  discipline_id = p_discipline_id;
    commit;
    exception when others then raise_application_error(-20001, sqlerrm);
  end;
  
procedure delete_discipline(
  p_discipline_id     in number) is
  begin
    -- пометка дисциплины к удалению
    update dict_discipline
    set    deleted       = 1
    where  discipline_id = p_discipline_id;
    commit;
    exception when others then
    begin
      rollback;
      raise_application_error(-20001, sqlerrm);
    end;
  end;
  
procedure insert_course(
  p_name              in varchar2,
  p_discipline_id     in number,
  p_cost_value        in number,
  p_duration          in number) is
  begin
    insert into dict_course (
      name,
      discipline_id,
      cost_value,
      duration)
    values (
      p_name,
      p_discipline_id,
      p_cost_value,
      p_duration);
    commit;
    exception when others then raise_application_error(-20001, sqlerrm);
  end;
  
procedure update_course(
  p_name               in varchar2,
  p_discipline_id      in number,
  p_cost_value         in number,
  p_duration           in number,
  p_course_id          in number) is
  begin
    update dict_course
    set    name          = p_name,
           discipline_id = p_discipline_id,
           cost_value    = p_cost_value,
           duration      = p_duration
    where  course_id     = p_course_id;
    commit;
    exception when others then raise_application_error(-20001, sqlerrm);
  end;
  
procedure delete_course(
  p_course_id          in number) is
  begin
    update dict_course
    set    deleted   = 1
    where  course_id = p_course_id;
    commit;
    exception when others then raise_application_error(-20001, sqlerrm);
  end;
  
function string_to_table(
  p_list              in varchar2,
  p_split             in varchar2) return var_type
  is
  p_string      varchar2(32767):=p_list||p_split;
  p_comma_index pls_integer;
  p_index       pls_integer:=1;
  p_tab         var_type:=var_type();
  begin
    loop
      p_comma_index:=instr(p_string, p_split, p_index);
      exit when p_comma_index = 0;
      p_tab.extend;
      p_tab(p_tab.count):=trim(substr(p_string, 
                                      p_index, 
                                      p_comma_index - p_index
                                     )
                              );
      p_index:=p_comma_index + 1;
    end loop;
    return p_tab;
  end;
  
procedure init_student_course_pty(
  p_student_id        in number,
  p_course_str        in varchar2,
  p_split             in varchar2) is
  begin
    -- 1. удаление текущих привязок
    delete from student_course_pty where student_id = p_student_id;
    -- 2. 
    for i in (select distinct * from table(mentor_pack.string_to_table(p_course_str, p_split))) loop
      insert into student_course_pty (student_id, course_id) values (p_student_id, i.column_value);
    end loop;
    commit;
    exception when others then
    begin
      rollback;
      raise_application_error(-20001, sqlerrm);
    end;
  end;
  
function check_crossing(
  p_course_id          in number,
  p_begin_date         in date,
  p_end_date           in date,
  p_mentor_schedule_id in number) return number
  is
  result number(1);
  begin
    select case count(*) when 0 then 0 else 1 end
    into   result
    from   v_schedule ms
    left join v_course dc on dc.course_id = p_course_id and dc.course_id = ms.course_id
    where  least(p_end_date, ms.end_date) > greatest(p_begin_date, ms.begin_date) and
           ms.mentor_schedule_id <> p_mentor_schedule_id;
    return result;
    exception when others then raise_application_error(-20001, sqlerrm);
  end;
  
procedure insert_mentor_schedule(
  p_course_id          in number,
  p_student_id         in number,
  p_begin_date         in date,
  p_end_date           in date) is
  -- 
  begin
    if p_course_id is null then
      raise_application_error(-20001, 'Необходимо указать курс');
    end if;
    -- 
    if p_student_id is null then
      raise_application_error(-20001, 'Необходимо указать ученика');
    end if;
    -- 
    if p_begin_date is null then
      raise_application_error(-20001, 'Необходимо указать дату и время начала занятия');
    end if;
    -- 
    if p_end_date is null then
      raise_application_error(-20001, 'Необходимо указать дату и время окончания занятия');
    end if;
    -- 
    if check_crossing(
         p_course_id,
         p_begin_date,
         p_end_date,
         null) = 0 then
      insert into mentor_schedule (
        course_id,
        student_id,
        begin_date,
        end_date)
      values (
        p_course_id,
        p_student_id,
        p_begin_date,
        p_end_date);
     else
      raise_application_error(-20001, 'Присутствует пересечение занятий');
    end if;
  end;
  
procedure update_mentor_schedule(
  p_course_id          in number,
  p_student_id         in number,
  p_begin_date         in date,
  p_end_date           in date,
  p_mentor_schedule_id in number)
  is
  p_state number(1);
  begin
    if p_mentor_schedule_id is null then
      raise_application_error(-20001, 'Необходимо выбрать запись');
    end if;
    -- 
    if p_course_id is null then
      raise_application_error(-20001, 'Необходимо указать курс');
    end if;
    -- 
    if p_student_id is null then
      raise_application_error(-20001, 'Необходимо указать ученика');
    end if;
    -- 
    if p_begin_date is null then
      raise_application_error(-20001, 'Необходимо указать дату и время начала занятия');
    end if;
    -- 
    if p_end_date is null then
      raise_application_error(-20001, 'Необходимо указать дату и время окончания занятия');
    end if;
    -- 
    select state into p_state from v_schedule where mentor_schedule_id = p_mentor_schedule_id;
    if p_state = 1 then
      raise_application_error(-20001, 'Запрещено редактировать состоявшиеся занятия');
    end if;
    -- 
    if check_crossing(
         p_course_id,
         p_begin_date,
         p_end_date,
         p_mentor_schedule_id) = 0 then
      update mentor_schedule
      set    course_id  = p_course_id,
             student_id = p_student_id,
             begin_date = p_begin_date,
             end_date   = p_end_date
      where  mentor_schedule_id = p_mentor_schedule_id;
     else
      raise_application_error(-20001, 'Присутствует пересечение занятий');
    end if;
  end;
  
procedure update_mentor_schedule(
  p_mentor_schedule_id in number)
  is
  p_state number(1);
  begin
    select state into p_state from v_schedule where mentor_schedule_id = p_mentor_schedule_id;
    if p_state = 1 then
      raise_application_error(-20001, 'Запрещено удалять состоявшиеся занятия');
    end if;
    -- удаление записи расписания
    delete from mentor_schedule
    where  mentor_schedule_id = p_mentor_schedule_id;
    exception when others then raise_application_error(-20001, sqlerrm);
  end;

procedure init_mentor_schedule(
  p_begin_date        in date,
  p_day_count         in number)
  is
  p_minute       number:=1/1440;
  p_reserve      number:=5/1440; -- "окно" в 5 минут
  p_cur_dt       date;
  p_incr_dt      date;
  p_max_course   number(1):=2;
  -- ограничение на максимальное количество занятий в неделю
  function get_course_count(
    p_course_id  in number,
    p_student_id in number) return number
  is
  result number;
  begin
    select count(*)
    into   result
    from   v_schedule
    where  course_id = p_course_id
       and student_id = p_student_id
       and trunc(begin_date, 'dd') >= p_begin_date;
    return result;
  end;
  -- 
  begin
    -- по всему диапазону дней (на каждого ученика по каждому курсу не более одного занятия в день)
    for date_i in (select (to_date(to_char(p_begin_date, 'dd.mm.yyyy')||' 08:30', 'dd.mm.yyyy hh24:mi')) + rownum - 1 begin_dt,
                          (to_date(to_char(p_begin_date, 'dd.mm.yyyy')||' 17:30', 'dd.mm.yyyy hh24:mi')) + rownum - 1 end_dt
                   from dual
                   connect by level <= p_day_count
                   order by 1)
    loop
      p_cur_dt:=date_i.begin_dt;
      -- привязки
      for pty_i in (select    scp.student_id, scp.course_id, vc.duration
                    from      student_course_pty scp
                    left join v_student vs on vs.student_id = scp.student_id
                    left join v_course vc on vc.course_id = scp.course_id
                    order by  1, 2)
      loop
        -- дата и время окончания занятия
        p_incr_dt:=p_cur_dt + (p_minute * pty_i.duration);
        if  p_incr_dt <= date_i.end_dt 
         then
          begin
            if get_course_count(pty_i.course_id, pty_i.student_id) < p_max_course then
              mentor_pack.insert_mentor_schedule(
                p_course_id         => pty_i.course_id,
                p_student_id        => pty_i.student_id,
                p_begin_date        => p_cur_dt,
                p_end_date          => p_incr_dt);
              p_cur_dt:=p_incr_dt + p_reserve;
            end if;
          end;
         else exit; -- переход к следующему дню
        end if;
      end loop;
    end loop;
  end;
  
procedure approve_mentor_schedule_row(
  p_mentor_schedule_id in number)
  is
  p_pay_value          number;
  p_service_value      number;
  p_tax_value          number;
  p_income_value       number;
  p_required_pay_count number;
  p_cur_pay_count      number;
  begin
    -- расчет значений атрибутов платежа
    select vc.cost_value,
           vsc.required_pay_count,
           (select count(*) from v_payment where student_id = vs.student_id) cur_pay_count
    into   p_pay_value,
           p_required_pay_count,
           p_cur_pay_count
    from   v_schedule vs
    left join v_course vc on vc.course_id = vs.course_id
    left join v_service vsc on vsc.service_id = vs.service_id
    where  vs.mentor_schedule_id = p_mentor_schedule_id;
    if p_cur_pay_count < p_required_pay_count then
      begin
        p_service_value:=p_pay_value;
        p_tax_value:=0;
        p_income_value:=0;
      end;
     else
      begin
        p_service_value:=0;
        p_tax_value:=p_pay_value * 0.04;
        p_income_value:=p_pay_value - p_tax_value;
      end;
    end if;
    -- добавление платежа
    insert into mentor_payment (
      mentor_schedule_id,
      pay_value,
      service_value,
      tax_value,
      income_value)
    values (
      p_mentor_schedule_id,
      p_pay_value,
      p_service_value,
      p_tax_value,
      p_income_value);
    -- фиксация статуса занятия
    update mentor_schedule
    set    state = 1
    where  mentor_schedule_id = p_mentor_schedule_id;
    exception when others then
    begin
      rollback;
      raise_application_error(-20001, sqlerrm);
    end;
  end;
  
procedure approve_mentor_schedule is
  begin
    for i in (select   mentor_schedule_id
              from     v_schedule
              where    state is null
              order by begin_date)
    loop
      mentor_pack.approve_mentor_schedule_row(i.mentor_schedule_id);
    end loop;
    -- фиксация транзакции
    commit;
    exception when others then
    begin
      rollback;
      raise_application_error(-20001, sqlerrm);
    end;
  end;

end;