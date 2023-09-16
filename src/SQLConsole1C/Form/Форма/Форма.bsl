﻿// Строка подключения к серверу. 
&НаКлиенте
Перем СоединениеСВнешнимиИД;

// Процедура определяет первоначальные параметры формы, отрабатывает перед открытием.
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
		
	ДоменнаяАвторизация=Истина;
	
	Элементы.Логин.Доступность=Ложь;
	
	Элементы.Пароль.Доступность=Ложь;
	
	Переключатель=1;
	
	Элементы.ГруппаСтрокиПодключения.Доступность=Истина;
	
	Элементы.ГруппаФайла.Доступность=Ложь;
	
	Элементы.ГруппаРучныхНастроекПодключения.Доступность=Ложь;
	
	МассивТипов = новый Массив;
	
	МассивТипов.Добавить(Тип("Строка"));
	
	НовыеРеквизиты = Новый Массив;
	
	НовыеРеквизиты.Добавить(Новый РеквизитФормы(
		"Результат",новый ОписаниеТипов(МассивТипов), "Ответ")
		);
	
	ИзменитьРеквизиты(НовыеРеквизиты);
	
	НовыйЭлемент = Элементы.Добавить("Ответ_Результат", Тип("ПолеФормы"), Элементы["ОтветРезультат"]);
	
    НовыйЭлемент.Вид = ВидПоляФормы.ПолеВвода;
	
    НовыйЭлемент.ПутьКДанным = "Ответ.Результат";
	
	если ДеревоЗапросов.ПолучитьЭлементы().Количество() = 0 тогда
		
		НовыйЭлемент = ДеревоЗапросов.ПолучитьЭлементы().Добавить();
		
		НовыйЭлемент.НаименованиеЗапроса = "Запрос_"+ДеревоЗапросов.ПолучитьЭлементы().Количество();
		
	КонецЕсли;
	
КонецПроцедуры

// Выбираем способ подключения к серверу.
//
// 1. готовая строка подключения.
// 2. подключение с помощью файла *.udl
// 3. пошаговое заполнение параметров строки подключения.
//
&НаКлиенте
Процедура ПереключательПриИзменении(Элемент)
	
	если Переключатель = 1 тогда
		
		Элементы.ГруппаСтрокиПодключения.Доступность=Истина;
		
		Элементы.ГруппаФайла.Доступность=Ложь;
		
		Элементы.ГруппаРучныхНастроекПодключения.Доступность=Ложь;
		
	ИначеЕсли Переключатель = 2 тогда
		
		Элементы.ГруппаСтрокиПодключения.Доступность=Ложь;
		
		Элементы.ГруппаФайла.Доступность=Истина;
		
		Элементы.ГруппаРучныхНастроекПодключения.Доступность=Ложь;
		
	ИначеЕсли Переключатель = 3 тогда
		
		Элементы.ГруппаСтрокиПодключения.Доступность=Ложь;
		
		Элементы.ГруппаФайла.Доступность=Ложь;
		
		Элементы.ГруппаРучныхНастроекПодключения.Доступность=Истина;
		
		Если Элементы.ПоставщикУслуг.СписокВыбора.Количество()=0 тогда
		
			Попытка
			
				PowerShellCOM = Новый COMОбъект("WScript.Shell");
			
			исключение
				
				Сообщить("Не удалось создать COM объект WScript.Shell. " + ОписаниеОшибки());
				
			КонецПопытки;
			
			ТекстСкрипта = "PowerShell -executionpolicy unrestricted -Command ""foreach ($x in [System.Data.OleDb.OleDbEnumerator]::GetRootEnumerator()) {'{0,-30} {1,-60}' -f $x.Item(0), $x.Item(2)}""";
			
			ВыполнениеСкрипта=PowerShellCOM.Exec(ТекстСкрипта);
			
			Sleep(3);
			
			ВыходнойПоток=ВыполнениеСкрипта.StdOut;
			
			Элементы.ПоставщикУслуг.СписокВыбора.Очистить();
			
			пока НЕ ВыходнойПоток.AtEndOfStream цикл
				
				Разбор(ВыходнойПоток.ReadLine());
				
			КонецЦикла;
			
			ВыполнениеСкрипта.Terminate();
			
			PowerShellCOM = Неопределено;
		
		КонецЕсли;
		
	КонецЕсли;
	
КонецПроцедуры

// Процедура выбора файла *.udl.
&НаКлиенте
Процедура ВыбратьФайл(Команда)
	
	Диалог = Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.Открытие);
	
	Диалог.Фильтр = "Файл связи с данными (*.udl)|*.udl";
	
	Диалог.Заголовок = "Выберите файл";
	
	Диалог.ПредварительныйПросмотр = Ложь;
	
	Диалог.Расширение = "udl";
	
	Диалог.ИндексФильтра = 0;
	
	Диалог.ПолноеИмяФайла = "";
	
	Диалог.ПроверятьСуществованиеФайла = Истина;
	
	Если Диалог.Выбрать() Тогда
		
		ПутьКФайлу = Диалог.ПолноеИмяФайла;
		
	Иначе
		
	    Возврат;
		
	КонецЕсли;
	
КонецПроцедуры

// Задержка (пауза) на <сек> сеунд.
&НаСервере
процедура Sleep(сек)
	
	КонДата = ТекущаяДата() + сек;
	
	Пока ТекущаяДата() < КонДата Цикл
		
	КонецЦикла;	
	
КонецПроцедуры

// Процедура разбора полученной строки, после выполнения скрипта PowerShell
// с помощью которого, в процедуре «ПереключательПриИзменении», мы получаем список OLE DB провайдеров, установленных на машине.
// И заполняем поле выбора "ПоставщикУслуг", полученными значениями.
&НаСервере
Процедура Разбор(СтрокаПереданная)
	
	ЗначениеНайденный=СокрЛП(Лев(СтрокаПереданная,СтрНайти(СтрокаПереданная," ",НаправлениеПоиска.СНачала,1,5)-1));
	
	ПредставлениеНайденное=СокрЛП(Прав(СтрокаПереданная,СтрДлина(СтрокаПереданная)-СтрНайти(СтрокаПереданная," ",НаправлениеПоиска.СКонца,,9)));
	
	если СтрЧислоВхождений(ЗначениеНайденный," ")=0 тогда 
		
		Элементы.ПоставщикУслуг.СписокВыбора.Добавить(ЗначениеНайденный,ПредставлениеНайденное);
		
	КонецЕсли;
	
КонецПроцедуры

// Определяем действие переключателя ДоменнаяАвторизация.
&НаКлиенте
Процедура ДоменнаяАвторизацияПриИзменении(Элемент)
	
	Если ДоменнаяАвторизация=Истина тогда
		
		Элементы.Логин.Доступность=Ложь;
	
		Элементы.Пароль.Доступность=Ложь;
		
	иначе
		
		Элементы.Логин.Доступность=Истина;
	
		Элементы.Пароль.Доступность=Истина;
		
	КонецЕсли;
		
КонецПроцедуры

// Обработка действия нажатия на кнопку "Подключиться к серверу".
&НаКлиенте
Процедура ПодключитьсяКСерверу(Команда)
	
	если Переключатель = 1 Тогда
		
			Если СтрокаПодлючения="" Тогда 
		
				Сообщить("Не заданы параметры подключения к серверу.");
				
				Возврат;
				
			КонецЕсли;
		
		ФинальнаяСтрокаПодключенияКСерверу = СтрокаПодлючения;
		
	ИначеЕсли Переключатель = 2 Тогда
		
			Если ПутьКФайлу="" Тогда 
		
				Сообщить("Файл подключения к серверу не найден.");
				
				Возврат;
				
			КонецЕсли;
		
		ФинальнаяСтрокаПодключенияКСерверу = "File Name=" + ПутьКФайлу;
		
	ИначеЕсли Переключатель = 3 Тогда
		
		//
		
		если ПоставщикУслуг = "" тогда
			
			Provider = "SQLOLEDB.1";
			
		Иначе
			
			Provider = ПоставщикУслуг;	
			
		КонецЕсли;
		
		если ИмяСервера = "" Тогда
			
			Сообщить("Сервер не указан.");
			
			Возврат;
			
		иначе
		
			DataSource = ИмяСервера;
		
		КонецЕсли;
		
		если ДоменнаяАвторизация = Истина Тогда
			
			PersistSecurityInfo = "False";
			
		иначеесли ДоменнаяАвторизация = Ложь Тогда
			
			PersistSecurityInfo = "True";
			
		КонецЕсли;
			
		если ДоменнаяАвторизация = Ложь и Логин = "" Тогда
			
			Сообщить("Логин не заполнен.");
			
			Возврат;
			
		иначе
			
			UserID = Логин;	
			
		КонецЕсли;
	
	    Password = Пароль;
		
		если БазаДанных = "" тогда
			
			Сообщить("Не указана база данных");
			
			Возврат;
			
		Иначе 
			
			InitialCatalog = БазаДанных;	
			
		КонецЕсли;
			
		// Возврат;
		
		ФинальнаяСтрокаПодключенияКСерверу="";
		
		ФинальнаяСтрокаПодключенияКСерверу = "Provider="+Provider
				                            +";Data Source="+DataSource
											+";Initial Catalog="+InitialCatalog
											+";Persist Security Info="+PersistSecurityInfo;
											
		если ДоменнаяАвторизация = Ложь Тогда
												
			ФинальнаяСтрокаПодключенияКСерверу = ФинальнаяСтрокаПодключенияКСерверу	+";User ID="+UserID
																					+";Password="+Password;
		КонецЕсли;
											
		
	КонецЕсли;
	
	СоединениеСВнешнимиИД = Новый COMОбъект("ADODB.Connection");
	
	Попытка
		
		СоединениеСВнешнимиИД.Open(ФинальнаяСтрокаПодключенияКСерверу);
		
	Исключение
		
		Сообщить("Не удалось подключиться к серверу: " + ОписаниеОшибки());
		
		Возврат;
		
	КонецПопытки;
	
	Сообщить("Подключение к серверу прошло успешно.");
		
	Элементы.ОтключитьсяОтСервера.Доступность = Истина;
		
	Элементы.ПодключитьсяКСерверу.Доступность = Ложь;
		
КонецПроцедуры

// Обработка действия нажатия на кнопку "Отключиться от сервера".
&НаКлиенте
Процедура ОтключитьсяОтСервера(Команда)
	
	Попытка
		
		СоединениеСВнешнимиИД.Close();
				
	Исключение
		
		Сообщить("Не удалось закрыть подключение к серверe: " + ОписаниеОшибки());
		
		Возврат;
		
	КонецПопытки;
	
	Сообщить("Подключение к серверу успешно закрыто.");
	
	СоединениеСВнешнимиИД = Неопределено;
	
	Элементы.ОтключитьсяОтСервера.Доступность = Ложь;
	
	Элементы.ПодключитьсяКСерверу.Доступность = Истина;
	
КонецПроцедуры

// Выполняем запрос к подключенной базе данных.
&НаКлиенте
Процедура ОтправитьЗапрос(Команда)
	
	Если СоединениеСВнешнимиИД = неопределено Тогда
		
		Сообщить("Нет подключения к базе данных.");
		
		Возврат;
		
	КонецЕсли;
	
	Если ТекстЗапроса="" Тогда 
		
		Сообщить("Текст запроса не определен.");
		
		Возврат;
		
	КонецЕсли;
	
	попытка
		
		ЭтотОтвет = СоединениеСВнешнимиИД.Execute(ТекстЗапроса);
		
	исключение
		
		Сообщить("Запрос вернул ошибку " + ОписаниеОшибки());
		
		Возврат;
		
	КонецПопытки;
	
	ОчиститьОтвет();
	
	МассивДанных = Новый Массив;
	
	Пока ЭтотОтвет.EOF() = 0 Цикл
		
		СтруктураСтрокаТаблицы = Новый Структура;
		
		Для Каждого ИмяКолонки Из ЭтотОтвет.Fields Цикл
			
			СтруктураСтрокаТаблицы.Вставить(
				ПривестиИмяКДопустимому(ИмяКолонки.Name,СтруктураСтрокаТаблицы), 	// Передаем в процедуру ПривестиИмяКДопустимому имена полей и существующую структуру.  
				ЭтотОтвет.Fields(ИмяКолонки.Name).Value
				);	
			
		КонецЦикла;
		
		МассивДанных.Добавить(СтруктураСтрокаТаблицы);
		
		ЭтотОтвет.MoveNext();
		
	КонецЦикла;
	
	СформироватьТЗ(МассивДанных); 	// В результате получаем массив структур. На клиенте мы не можем работать с Таблицей Значений.
	
КонецПроцедуры

// Очищаем таблицу значений. 
// Важно! Очищаем и серверную часть и клиентскую.
&НаСервере
Процедура ОчиститьОтвет()
	
	если Элементы["ОтветРезультат"].ПодчиненныеЭлементы.Количество()>0 тогда 	// Проверяем количество колонок в таблице значений.
		
		ответ.Очистить(); 														// Очищаем строки.
		
		// Очищаем Серверную часть таблицы значений т.е. ее структуру которая хранится на сервере.
		
		для каждого Калонка из Элементы["ОтветРезультат"].ПодчиненныеЭлементы цикл
			
			ЭлементНаУдаление = Элементы.Найти(Калонка.Имя);
			
			если НЕ ЭлементНаУдаление = Неопределено тогда
				
				Элементы.Удалить(ЭлементНаУдаление);	
				
			КонецЕсли;
			
		КонецЦикла;
		
		// Очищаем элементы формы, таблицы значений, которые отображаются на форме.
			
		УдаляемыеРеквизиты = Новый Массив;
		
		Для каждого Колонка из Ответ.Выгрузить(,).Колонки Цикл
			
			УдаляемыеРеквизиты.Добавить("Ответ." + Колонка.Имя);
			
		КонецЦикла;
		
		ИзменитьРеквизиты(,УдаляемыеРеквизиты);
	
	КонецЕсли;
	
КонецПроцедуры

// Проверяем правильность имени поля, полученного в ответе на запрос.
&НаКлиенте
Функция ПривестиИмяКДопустимому(СтрокаИмени,ИмеющаясяСтруктура)
	
	РезультатПреобразования = СтрокаИмени;
	
	если СтрЧислоВхождений(РезультатПреобразования," ") > 0 тогда
		
		РезультатПреобразования = ПреобразованиеИмениПоля(
															РезультатПреобразования,
															СтрЧислоВхождений(СтрокаИмени," "),
															" ")
		; // удалим пробелы
		
	КонецЕсли;
	
	если СтрЧислоВхождений(РезультатПреобразования,Символы.Таб) > 0 тогда
		
		РезультатПреобразования = ПреобразованиеИмениПоля(
															РезультатПреобразования,
															СтрЧислоВхождений(РезультатПреобразования,Символы.Таб),
															Символы.Таб
		); // удалим знак табуляции
		
	КонецЕсли;
	
	если СтрЧислоВхождений(РезультатПреобразования,"(") > 0 тогда
		
		РезультатПреобразования = ПреобразованиеИмениПоля(
															РезультатПреобразования,
															СтрЧислоВхождений(РезультатПреобразования,"("),
															"("
		); // удалим знаки скобок
		
	КонецЕсли;
	
	если СтрЧислоВхождений(РезультатПреобразования,")") > 0 тогда
		
		РезультатПреобразования = ПреобразованиеИмениПоля(
															РезультатПреобразования,
															СтрЧислоВхождений(РезультатПреобразования,")"),
															")"
		); // удалим знаки скобок
		
	КонецЕсли;	
	
	если СтрЧислоВхождений(РезультатПреобразования,"-") > 0 тогда
		
		РезультатПреобразования = ПреобразованиеИмениПоля(
															РезультатПреобразования,
															СтрЧислоВхождений(РезультатПреобразования,"-"),
															"-"
		); // удалим дефис
		
	КонецЕсли;
	
	если СтрЧислоВхождений(РезультатПреобразования,"%") > 0 тогда
		
		РезультатПреобразования = ПреобразованиеИмениПоля(
															РезультатПреобразования,
															СтрЧислоВхождений(РезультатПреобразования,"%"),
															"%"
		); // удалим знак %
		
	КонецЕсли;
	
	если СтрЧислоВхождений(РезультатПреобразования,"#") > 0 тогда
		
		РезультатПреобразования = ПреобразованиеИмениПоля(
															РезультатПреобразования,
															СтрЧислоВхождений(РезультатПреобразования,"#"),
															"#"
		); // удалим знак #
		
	КонецЕсли;
	
	если СтрЧислоВхождений(РезультатПреобразования,"№") > 0 тогда
		
		РезультатПреобразования = ПреобразованиеИмениПоля(
															РезультатПреобразования,
															СтрЧислоВхождений(РезультатПреобразования,"№"),
															"№"
		); // удалим знак №
		
	КонецЕсли;
	
	если СтрЧислоВхождений(РезультатПреобразования,"/") > 0 тогда
		
		РезультатПреобразования = ПреобразованиеИмениПоля(
															РезультатПреобразования,
															СтрЧислоВхождений(РезультатПреобразования,"/"),
															"/"
		); // удалим знак /
		
	КонецЕсли;
	
	если СтрЧислоВхождений(РезультатПреобразования,"\") > 0 тогда
		
		РезультатПреобразования = ПреобразованиеИмениПоля(
															РезультатПреобразования,
															СтрЧислоВхождений(РезультатПреобразования,"\"),
															"\"
		); // удалим знак \
		
	КонецЕсли;
		
	Если ИмеющаясяСтруктура.Свойство(РезультатПреобразования) = Истина Тогда
		
		РезультатПреобразования = РезультатПреобразования + "_";
		
		ПривестиИмяКДопустимому(РезультатПреобразования,ИмеющаясяСтруктура);
		
	КонецЕсли;

	Возврат РезультатПреобразования;
	
КонецФункции

// Функция подменяет заданный символ в строке на "_" известное число вхождений.
&НаКлиенте
Функция ПреобразованиеИмениПоля(Строка,КоличествоВхождений, ИскомыйСимвол)
	
	ИтераторДляЦикла=0;
	
	пока КоличествоВхождений > ИтераторДляЦикла цикл
	
		Строка = СтрЗаменить(Строка,ИскомыйСимвол,"_");
	
		ИтераторДляЦикла = ИтераторДляЦикла + 1;
	
	КонецЦикла;	
	
	Возврат Строка;
	
КонецФункции

// Преобразуем полученный на клиенте массив структур в Таблицу значений.
&НаСервере
Процедура СформироватьТЗ(МассивДанных)
	
	СформированнаяТЗ = Новый ТаблицаЗначений;
	
	Для Каждого ЭлементМассива Из МассивДанных Цикл
		
		Если СформированнаяТЗ.Колонки.Количество() = 0 Тогда
			
			Для Каждого ЗначениеСтруктуры Из ЭлементМассива Цикл
				
                СформированнаяТЗ.Колонки.Добавить(ЗначениеСтруктуры.Ключ);
				
			КонецЦикла;
			
		КонецЕсли;
		
        НоваяСтрока = СформированнаяТЗ.Добавить();
		
		Для Каждого ЗначениеСтруктуры Из ЭлементМассива Цикл
			
            НоваяСтрока[ЗначениеСтруктуры.Ключ] = ЗначениеСтруктуры.Значение;
			
		КонецЦикла;
		
	КонецЦикла;
	
	КолонкиОтвета(СформированнаяТЗ,"Ответ","ОтветРезультат")
	
КонецПроцедуры

// Согласно полученной таблицы значений формируем отображение на форме.
&НаСервере
Процедура КолонкиОтвета(СформированнаяТЗ,Ответ1,ОтветРезультат1)
	
	// Формируем структуру таблицы значений на сервере для отображения на клиенте (на форме)
	
	НовыеРеквизиты = Новый Массив;
	
	Для Каждого Колонка Из СформированнаяТЗ.Колонки Цикл
		
         НовыеРеквизиты.Добавить(Новый РеквизитФормы(Колонка.Имя, Колонка.ТипЗначения, Ответ1));
		 
	КонецЦикла;
	 
	// Формируем отображения элемента формы согласно полученной структуре. 
	 
	ИзменитьРеквизиты(НовыеРеквизиты);
	
	Для Каждого Колонка Из СформированнаяТЗ.Колонки Цикл
		
        НовыйЭлемент = Элементы.Добавить(Ответ1 + "_" + Колонка.Имя, Тип("ПолеФормы"), Элементы[ОтветРезультат1]);
		
        НовыйЭлемент.Вид = ВидПоляФормы.ПолеВвода;
		
        НовыйЭлемент.ПутьКДанным = Ответ1 + "." + Колонка.Имя;
		
	КонецЦикла;
	
	ЗначениеВРеквизитФормы(СформированнаяТЗ, Ответ1); 	// заполняем Таблицу значений на форме, значениями из полученной Таблицы значений.
	
КонецПроцедуры

// Действие перед закрытием формы. Обязательно проверяем открыто ли соединение на сервер, 
// и если соединение открыто, то нужно его обязательно закрыть перед закрытием формы.
&НаКлиенте
Процедура ПередЗакрытием(Отказ, ЗавершениеРаботы, ТекстПредупреждения, СтандартнаяОбработка)
	
	Если СоединениеСВнешнимиИД = неопределено Тогда
		
	иначе
		
		СоединениеСВнешнимиИД.Close();	
		
	КонецЕсли;
	
	Элементы.ОтключитьсяОтСервера.Доступность = Ложь;
		
	Элементы.ПодключитьсяКСерверу.Доступность = Истина;
	
	//Если СокрЛП(ТекстЗапроса) <> "" Тогда 
	//	
	//	Оповещение = Новый ОписаниеОповещения(
	//											"ПослеЗакрытияВопроса",
	//											ЭтаФорма
	//	);
	//
	//	ПоказатьВопрос(
	//					Оповещение, 
	//					"Вы хотите сохранить этот SQL запрос в файл?", 
	//					РежимДиалогаВопрос.ДаНет,, 
	//					КодВозвратаДиалога.Нет, 
	//					"Сохранение файла"
	//	);
	//
	//КонецЕсли;
		
КонецПроцедуры

 //Оповещение после вопроса о сохранении SQL запроса в файл перед закрытием. (НЕ ЗАДЕЙСТВОВАНА)
&НаКлиенте
Процедура ПослеЗакрытияВопроса(Результат, Параметры) Экспорт
// 
//	Если Результат = КодВозвратаДиалога.Нет Тогда
//		
//	    Возврат; 
//		
//	ИначеЕсли Результат = КодВозвратаДиалога.Да Тогда 
//		
//		СохраняемЗапросВФайлНаДиск();	
//		
//	КонецЕсли;	
// 
КонецПроцедуры

// Обработка действия нажатия на кнопку "Сохранить запрос". 
&НаКлиенте
Процедура СохранитьЗапрос(Команда)
	
	СохраняемЗапросВФайлНаДиск();
	
КонецПроцедуры

// Процедура записи файла SQL запроса.
&НаКлиенте
Процедура СохраняемЗапросВФайлНаДиск()
	
	ПутьКФайлу = ДиалогСохраненияФайлаНаДиск(); 	// Получаем имя и путь к файлу.
	
	если ПутьКФайлу = "" тогда 
		
		Возврат;
		
	КонецЕсли;
	
	// Следующая конструкция нужна, что бы сохранить файл в кодировке UTF-8 без BOM.
	
	ФайлТХТ = Новый ЗаписьТекста(
									ПутьКФайлу,
									КодировкаТекста.ANSI
	);
	
	ФайлТХТ.Закрыть();
	
	ФайлТХТ = новый ЗаписьТекста(
									ПутьКФайлу,
									,
									,
									Истина,
									""
	);
	
	попытка
		
		ФайлТХТ.Записать(ТекстЗапроса);
		
	Исключение
		
		Сообщить("Файл sql запроса не был записан: " + ПутьКФайлу + " " + ОписаниеОшибки());
		
	КонецПопытки;
	
	ФайлТХТ.Закрыть();
	
КонецПроцедуры

// Функция выбора каталога, для сохранения файла SQL запроса.
&НаКлиенте
Функция ДиалогСохраненияФайлаНаДиск()
	
	ДиалогСохраненияФайла = 					Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.Сохранение); 
	
	ДиалогСохраненияФайла.ПолноеИмяФайла = Элементы.ДеревоЗапросов.ТекущиеДанные.НаименованиеЗапроса; 
	
	ДиалогСохраненияФайла.Фильтр = 				"Файл SQL зароса (*.sql)|*.sql"; 
	
	ДиалогСохраненияФайла.МножественныйВыбор = 	Ложь; 
	
	ДиалогСохраненияФайла.Заголовок = 			"Сохранить файл SQL запроса";
	
	Если ДиалогСохраненияФайла.Выбрать() Тогда 
		
		ПутьКФайлу = ДиалогСохраненияФайла.ПолноеИмяФайла; 
		
	иначе 
		
		ПутьКФайлу = "";
		
	КонецЕсли;
	
	Возврат ПутьКФайлу;
	
КонецФункции

// При переходе между элементами дерева запросов, сохраняет текст запроса в одном из реквизитов дерева значений.
&НаКлиенте
Процедура ТекстЗапросаПриИзменении(Элемент)
	
	ДеревоЗначенийНаФорме = 				Элементы.ДеревоЗапросов.ТекущиеДанные;
	
	ДеревоЗначенийНаФорме.ТекстЗапроса = 	ТекстЗапроса;
	
КонецПроцедуры

// Перед началом добавления нового элемента Дерева Запросов, убираем текст из Текста Запроса.
&НаКлиенте
Процедура ДеревоЗапросовПередНачаломДобавления(Элемент, Отказ, Копирование, Родитель, Группа, Параметр)
	
	ТекстЗапроса = "";
	
КонецПроцедуры

// Процедура обрабатывает активизацию строки (Элемента) Таблицы Запросов.
&НаКлиенте
Процедура ДеревоЗапросовПриАктивизацииСтроки(Элемент)
	
	КоличествоСтрок = ПодсчетСтрокДереваЗапросов(ДеревоЗапросов.ПолучитьЭлементы(),0);
	
	если  КоличествоСтрок <> 0 тогда
	
		ДеревоЗначенийНаФорме = 	Элементы.ДеревоЗапросов.ТекущиеДанные;
		
		ТекстЗапроса = 				ДеревоЗначенийНаФорме.ТекстЗапроса;
		
		// Для наименования нового запроса считаем количество строк Таблицы Запросов.
		
		если ДеревоЗначенийНаФорме.НаименованиеЗапроса = "" тогда
					
			ДеревоЗначенийНаФорме.НаименованиеЗапроса = "Запрос_" + КоличествоСтрок;	
			
		КонецЕсли;
	
	КонецЕсли;
	
КонецПроцедуры

// Функция подсчета количества строк Таблицы Запросов.
&НаКлиенте
Функция ПодсчетСтрокДереваЗапросов(СтрокиДереваЗначений,СуммаСтрок)
	
	Для Каждого Строки Из СтрокиДереваЗначений Цикл
		
		СуммаСтрок = 		СуммаСтрок + 1;
		
		ВложенныеСтроки = 	Строки.ПолучитьЭлементы();
		
		если ВложенныеСтроки.Количество() > 0 тогда
			
			СуммаСтрок = ПодсчетСтрокДереваЗапросов(ВложенныеСтроки, СуммаСтрок);			
				
		КонецЕсли;
		
	КонецЦикла;
	
	Возврат СуммаСтрок;
	
КонецФункции

// Обработка действия нажатия на кнопку "Открыть запрос".
&НаКлиенте
Процедура ОткрытьЗапрос(Команда)
	
	ПутьКФайлу = ДиалогОткрытияФайлаНаДиск();
	
	ЧитаемТекстИзФайла = новый ЧтениеТекста(ПутьКФайлу,КодировкаТекста.UTF8);
	
	ПолученныйТекстЗапроса = ЧитаемТекстИзФайла.Прочитать();
	
	НоваяСтрока = ДеревоЗапросов.ПолучитьЭлементы().Добавить();
	
	НоваяСтрока.НаименованиеЗапроса = "Запрос_" + ПодсчетСтрокДереваЗапросов(ДеревоЗапросов.ПолучитьЭлементы(),0);
	
	Элементы.ДеревоЗапросов.ТекущаяСтрока = НоваяСтрока.ПолучитьИдентификатор();
	
	НоваяСтрока.ТекстЗапроса = ПолученныйТекстЗапроса;
	
	ТекстЗапроса = ПолученныйТекстЗапроса;
	
КонецПроцедуры

// Функция выбора файла, для открытия файла SQL запроса.
&НаКлиенте
Функция ДиалогОткрытияФайлаНаДиск()
	
	ДиалогСохраненияФайла = 					Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.Открытие); 
	
	ДиалогСохраненияФайла.Фильтр = 				"Файл SQL зароса (*.sql)|*.sql"; 
	
	ДиалогСохраненияФайла.МножественныйВыбор = 	Ложь; 
	
	ДиалогСохраненияФайла.Заголовок = 			"Открыть файл SQL запроса";
	
	Если ДиалогСохраненияФайла.Выбрать() Тогда 
		
		ПутьКФайлу = ДиалогСохраненияФайла.ПолноеИмяФайла; 
		
	иначе 
		
		ПутьКФайлу = "";
		
	КонецЕсли;
	
	Возврат ПутьКФайлу;
	
КонецФункции
