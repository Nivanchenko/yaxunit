//©///////////////////////////////////////////////////////////////////////////©//
//
//  Copyright 2021-2023 BIA-Technologies Limited Liability Company
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
//©///////////////////////////////////////////////////////////////////////////©//

///////////////////////////////////////////////////////////////////
// ПрограммныйИнтерфейс
// Экспортные процедуры и функции для прикладного использования 
/////////////////////////////////////////////////////////////////// 

#Область ПрограммныйИнтерфейс

// СоздатьЭлемент
//  Создает новый элемент и возвращает его ссылку 
// Параметры:
//  Менеджер - Произвольный - Менеджер справочника/ПВХ и тд.
//  Наименование - Строка, Неопределено - Наименование элемента
//  Реквизиты - Структура, Неопределено - Значения реквизитов элемента
// 
// Возвращаемое значение:
//  ЛюбаяСсылка - Ссылка на созданный объект
Функция СоздатьЭлемент(Знач Менеджер, Знач Наименование = Неопределено, Знач Реквизиты = Неопределено) Экспорт
	
	Менеджер = ЮТОбщий.Менеджер(Менеджер);
	
	Объект = Менеджер.СоздатьЭлемент();
	
	Если ЗначениеЗаполнено(Наименование) Тогда
		Объект.Наименование = Наименование;
	ИначеЕсли Объект.Метаданные().ДлинаНаименования > 0 Тогда
		Объект.Наименование = ЮТТестовыеДанные.УникальнаяСтрока();
	КонецЕсли;
	
	Если Реквизиты <> Неопределено Тогда
		ЗаполнитьЗначенияСвойств(Объект, Реквизиты);
	КонецЕсли;
	
	Если Объект.Метаданные().ДлинаКода И НЕ ЗначениеЗаполнено(Объект.Код) Тогда
		Объект.УстановитьНовыйКод();
	КонецЕсли;
	
	ЗаписатьОбъект(Объект);
	
	Возврат Объект.Ссылка;
	
КонецФункции

// СоздатьДокумент
//  Создает новый документ и возвращает его ссылку 
// Параметры:
//  Менеджер - Произвольный - Менеджер справочника/ПВХ и тд.
//  Реквизиты - Структура, Неопределено - Значения реквизитов элемента
// 
// Возвращаемое значение:
//  ДокументСсылка - Ссылка на созданный объект
Функция СоздатьДокумент(Знач Менеджер, Знач Реквизиты = Неопределено) Экспорт
	
	РежимЗаписи = РежимЗаписиДокумента.Запись;
	
	Менеджер = ЮТОбщий.Менеджер(Менеджер);
	
	Объект = Менеджер.СоздатьДокумент();
	Объект.Дата = ТекущаяДатаСеанса();
	Объект.УстановитьНовыйНомер();
	
	Если Реквизиты <> Неопределено Тогда
		ЗаполнитьЗначенияСвойств(Объект, Реквизиты);
		РежимЗаписи = ЮТОбщий.ЗначениеСтруктуры(Реквизиты, "РежимЗаписи", РежимЗаписи);
	КонецЕсли;
	
	ЗаписатьОбъект(Объект, , РежимЗаписи);
	
	Возврат Объект.Ссылка;
	
КонецФункции

// Создать запись.
// 
// Параметры:
//  Менеджер - Произвольный
//  Данные - Структура - Данные заполнения объекта
//  ПараметрыЗаписи - см. ЮТОбщий.
//  ВернутьОбъект - Булево - Вернуть объект
// 
// Возвращаемое значение:
//  Произвольный - Создать запись
Функция СоздатьЗапись(Знач Менеджер, Знач Данные, Знач ПараметрыЗаписи = Неопределено, Знач ВернутьОбъект = Ложь) Экспорт
	
	Менеджер = ЮТОбщий.Менеджер(Менеджер);
	
	ОписаниеОбъектаМетаданных = ЮТМетаданные.ОписаниеОбъектМетаданных(ТипЗнч(Менеджер));
	
	Объект = СоздатьОбъект(Менеджер, ОписаниеОбъектаМетаданных.ОписаниеТипа);
	ЗаполнитьЗначенияСвойств(Объект, Данные);
	
	Если ОписаниеОбъектаМетаданных.ОписаниеТипа.ТабличныеЧасти Тогда
		
		Для Каждого ОписаниеТабличнойЧасти Из ОписаниеОбъектаМетаданных.ТабличныеЧасти Цикл
			
			ИмяТабличнойЧасти = ОписаниеТабличнойЧасти.Ключ;
			Если НЕ Данные.Свойство(ИмяТабличнойЧасти) Тогда
				Продолжить;
			КонецЕсли;
			
			Для Каждого Запись Из Данные[ИмяТабличнойЧасти] Цикл
				Строка = Объект[ИмяТабличнойЧасти].Добавить();
				ЗаполнитьЗначенияСвойств(Строка, Запись);
			КонецЦикла;
			
		КонецЦикла;
		
	КонецЕсли;
	
	Если ПараметрыЗаписи = Неопределено Тогда
		ПараметрыЗаписи = ЮТОбщий.ПараметрыЗаписи();
	Иначе
		ПереданныеПараметрыЗаписи = ПараметрыЗаписи;
		ПараметрыЗаписи = ЮТОбщий.ПараметрыЗаписи();
		ЗаполнитьЗначенияСвойств(ПараметрыЗаписи, ПереданныеПараметрыЗаписи);
	КонецЕсли;
	
	ЗаполнитьБазовыеРеквизиты(Объект, ОписаниеОбъектаМетаданных);
	
	ЮТОбщий.ОбъединитьВСтруктуру(Объект.ДополнительныеСвойства, ПараметрыЗаписи.ДополнительныеСвойства);
	
	РежимЗаписи = ?(СтрСравнить(ОписаниеОбъектаМетаданных.ОписаниеТипа.Имя, "Документ") = 0, ПараметрыЗаписи.РежимЗаписи, Неопределено);
	ЗаписатьОбъект(Объект, ПараметрыЗаписи.ОбменДаннымиЗагрузка, РежимЗаписи);
	
	Возврат ?(ВернутьОбъект, Объект, Объект.Ссылка);
	
КонецФункции

#КонецОбласти
/////////////////////////////////////////////////////////////////////////////////
// Экспортные процедуры и функции для служебного использования внутри подсистемы
///////////////////////////////////////////////////////////////////////////////// 

#Область СлужебныйПрограммныйИнтерфейс

Функция ФикцияЗначенияБазы(Знач ТипЗначения) Экспорт
	
	ОбъектМетаданных = Метаданные.НайтиПоТипу(ТипЗначения);
	
	Если ОбъектМетаданных = Неопределено Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	Если Метаданные.Перечисления.Содержит(ОбъектМетаданных) Тогда
		
		Менеджер = Новый ("ПеречислениеМенеджер." + ОбъектМетаданных.Имя);
		НомерЗначения = ЮТТестовыеДанные.СлучайноеПоложительноеЧисло(Менеджер.Количество());
		Возврат Менеджер.Получить(НомерЗначения - 1);
		
	КонецЕсли;
	
	ОписаниеОбъектаМетаданных = ЮТМетаданныеСервер.ОписаниеОбъектМетаданных(ОбъектМетаданных);
	ОписаниеТипа = ОписаниеОбъектаМетаданных.ОписаниеТипа;
	
	ИмяТипаМенеджера = СтрШаблон("%1Менеджер.%2", ОписаниеТипа.Имя, ОбъектМетаданных.Имя);
	Менеджер = Новый (ИмяТипаМенеджера);
	
	Объект = СоздатьОбъект(Менеджер, ОписаниеТипа);
	
	ЗаполнитьБазовыеРеквизиты(Объект, ОписаниеОбъектаМетаданных);
	
	ЗаписатьОбъект(Объект);
	
	Возврат Объект.Ссылка;
	
КонецФункции

#КонецОбласти

/////////////////////////////////////////////////////////////////////////////////
// Процедуры и функции, составляющие внутреннюю реализацию модуля 
///////////////////////////////////////////////////////////////////////////////// 

#Область СлужебныеПроцедурыИФункции

// Создать объект.
// 
// Параметры: ОписаниеМенеджера - 
// См. ОписаниеМенеджера
//  Менеджер - Произвольный - Менеджер
//  ОписаниеТипа - см. ЮТМетаданные.ОписаниеОбъектМетаданных
// 
// Возвращаемое значение:
//  Произвольный - Создать объект
Функция СоздатьОбъект(Менеджер, ОписаниеТипа)
	
	Если ОписаниеТипа.Конструктор = "СоздатьЭлемент" Тогда
		Результат = Менеджер.СоздатьЭлемент();
	ИначеЕсли ОписаниеТипа.Конструктор = "СоздатьДокумент" Тогда
		Результат = Менеджер.СоздатьДокумент();
	ИначеЕсли ОписаниеТипа.Конструктор = "СоздатьСчет" Тогда
		Результат = Менеджер.СоздатьСчет();
	ИначеЕсли ОписаниеТипа.Конструктор = "СоздатьВидРасчета" Тогда
		Результат = Менеджер.СоздатьВидРасчета();
	ИначеЕсли ОписаниеТипа.Конструктор = "СоздатьУзел" Тогда
		Результат = Менеджер.СоздатьУзел();
	ИначеЕсли ОписаниеТипа.Конструктор = "СоздатьНаборЗаписей" Тогда
		Результат = Менеджер.СоздатьНаборЗаписей();
	ИначеЕсли ОписаниеТипа.Конструктор = "СоздатьБизнесПроцесс" Тогда
		Результат = Менеджер.СоздатьБизнесПроцесс();
	ИначеЕсли ОписаниеТипа.Конструктор = "СоздатьЗадачу" Тогда
		Результат = Менеджер.СоздатьЗадачу();
	Иначе
		ВызватьИсключение СтрШаблон("Для %1 не поддерживается создание записей ИБ", ОписаниеТипа.Имя);
	КонецЕсли;
	
	Возврат Результат;

КонецФункции

Процедура ЗаписатьОбъект(Объект, ОбменДаннымиЗагрузка = Ложь, РежимЗаписи = Неопределено)
	
	Если ОбменДаннымиЗагрузка Тогда
		Объект.ОбменДанными.Загрузка = Истина;
	КонецЕсли;
	
	Попытка
		
		Если РежимЗаписи <> Неопределено Тогда
			Объект.Записать(РежимЗаписи);
		Иначе
			Объект.Записать();
		КонецЕсли;
		
	Исключение
		
		Сообщение = СтрШаблон("Не удалось записать объект `%1` (%2)
		|%3", Объект, ТипЗнч(Объект), ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));
		ВызватьИсключение Сообщение;
		
	КонецПопытки;
	
КонецПроцедуры

Процедура ЗаполнитьБазовыеРеквизиты(Объект, ОписаниеОбъектаМетаданных)
	
	ОписаниеТипа = ОписаниеОбъектаМетаданных.ОписаниеТипа;
	Если ОписаниеТипа.Имя = "Документ" Тогда
		Если НЕ ЗначениеЗаполнено(Объект.Дата) Тогда
			Объект.Дата = ТекущаяДатаСеанса();
		КонецЕсли;
		Если НЕ ЗначениеЗаполнено(Объект.Номер) Тогда
			Объект.УстановитьНовыйНомер();
		КонецЕсли;
	КонецЕсли;
	
	Если ОписаниеОбъектаМетаданных.Реквизиты.Свойство("Код")
		И ОписаниеОбъектаМетаданных.Реквизиты.Код.Обязательный
		И Не ЗначениеЗаполнено(Объект.Код) Тогда
		Объект.УстановитьНовыйКод();
	КонецЕсли;
	
	Если ОписаниеОбъектаМетаданных.Реквизиты.Свойство("Наименование")
		И ОписаниеОбъектаМетаданных.Реквизиты.Наименование.Обязательный
		И Не ЗначениеЗаполнено(Объект.Наименование) Тогда
		Объект.Наименование = ЮТТестовыеДанные.СлучайнаяСтрока();
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти
