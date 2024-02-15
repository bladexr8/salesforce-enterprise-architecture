// load sample data for Race Overview LWC
PageReference sampleData = new PageReference('/resource/sampledata');
String sampleDataJSON = sampleData.getContent().toString();
String orgNameSpace = SObjectDataLoader.class.toString().removeEnd('SObjectDataLoader').removeEnd('.');
SObjectDataLoader.deserialize(sampleDataJSON.replace('ns__', 
    orgNameSpace.length()==0 ? '' : orgNameSpace + '__'));