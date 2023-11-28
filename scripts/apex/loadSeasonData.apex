StaticResource sr = [SELECT ID, body FROM StaticResource WHERE Name = 'f1_2023_uow' LIMIT 1];
String seasonData = sr.body.toString();

// System.Debug(LoggingLevel.DEBUG, seasonData);

// load the Season Data
SeasonService.importSeasons(seasonData);