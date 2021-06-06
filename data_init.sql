-- добавление сервисов
  begin
    mentor_pack.insert_service(
      p_name               => 'Сервис 1',
      p_description        => 'Описание сервиса',
      p_required_pay_count => 3);
      
    mentor_pack.insert_service(
      p_name               => 'Сервис 2',
      p_description        => 'Описание сервиса',
      p_required_pay_count => 4);
  end;
/
  
-- добавление учеников
  begin
    -- 11 класс
    mentor_pack.insert_student(
      p_last_name         => 'Ученик_1',
      p_first_name        => 'Ученик_1',
      p_second_name       => 'Ученик_1');
      
    mentor_pack.insert_student(
      p_last_name         => 'Ученик_2',
      p_first_name        => 'Ученик_2',
      p_second_name       => 'Ученик_2',
      p_service_id        => 5);
      
    mentor_pack.insert_student(
      p_last_name         => 'Ученик_3',
      p_first_name        => 'Ученик_3',
      p_second_name       => 'Ученик_3');
      
      -- 6 класс
      mentor_pack.insert_student(
      p_last_name         => 'Ученик_4',
      p_first_name        => 'Ученик_4',
      p_second_name       => 'Ученик_4',
      p_service_id        => 10);
      
      mentor_pack.insert_student(
      p_last_name         => 'Ученик_5',
      p_first_name        => 'Ученик_5',
      p_second_name       => 'Ученик_5');

      mentor_pack.insert_student(
      p_last_name         => 'Ученик_6',
      p_first_name        => 'Ученик_6',
      p_second_name       => 'Ученик_6',
      p_service_id        => 5);
      
      mentor_pack.insert_student(
      p_last_name         => 'Ученик_7',
      p_first_name        => 'Ученик_7',
      p_second_name       => 'Ученик_7');
  end;
/
  
-- добавление дисциплин
  begin
    mentor_pack.insert_discipline(
      p_name              => 'Математика');
  end;
/
  
-- добавление курсов
  begin
    mentor_pack.insert_course(
      p_name              => 'Подготовка к ЕГЭ 11 класс',
      p_discipline_id     => 50,
      p_cost_value        => 2200,
      p_duration          => 90);
    
    mentor_pack.insert_course(
      p_name              => '6 кл. Алгебра (базовый курс)',
      p_discipline_id     => 50,
      p_cost_value        => 1500,
      p_duration          => 50);
      
    mentor_pack.insert_course(
      p_name              => '6 кл. Алгебра (продвинутый курс)',
      p_discipline_id     => 50,
      p_cost_value        => 1700,
      p_duration          => 60);
      
      
    mentor_pack.insert_course(
      p_name              => '6 кл. Геометрия',
      p_discipline_id     => 50,
      p_cost_value        => 1600,
      p_duration          => 40);
  end;
/
  
-- добавление привязок
  begin
    mentor_pack.init_student_course_pty(15, '55', ',');
    mentor_pack.init_student_course_pty(20, '55', ',');
    mentor_pack.init_student_course_pty(25, '55', ',');
    mentor_pack.init_student_course_pty(30, '60, 70', ',');
    mentor_pack.init_student_course_pty(35, '60', ',');
    mentor_pack.init_student_course_pty(40, '65, 70', ',');
    mentor_pack.init_student_course_pty(45, '70', ',');
  end;
/
  
  begin
    mentor_pack.init_mentor_schedule(to_date('07.06.2021', 'dd.mm.yyyy'), 7);
    mentor_pack.init_mentor_schedule(to_date('14.06.2021', 'dd.mm.yyyy'), 7);
    mentor_pack.init_mentor_schedule(to_date('21.06.2021', 'dd.mm.yyyy'), 7);
    mentor_pack.init_mentor_schedule(to_date('28.06.2021', 'dd.mm.yyyy'), 7);
  end;
/
  
  begin
    mentor_pack.approve_mentor_schedule;
  end;
/