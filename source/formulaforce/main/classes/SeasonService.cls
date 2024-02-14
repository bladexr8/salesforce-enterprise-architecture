public with sharing class SeasonService {
    
    public static void issueNewsLetterCurrentSeason() {
		throw new SeasonServiceException('Not implemented');
	}
	
	public static void issueNewsLetters(Set<Id> seasonIds) {
		throw new SeasonServiceException('Not implemented');		
	}

	public static void updateStandings(Set<Id> seasonIds) {
		throw new SeasonServiceException('Not implemented');
	}

	public static void updateStandings(List<UpdateStandings> updateStandings) {
		throw new SeasonServiceException('Not implemented');
	}

    public static void importSeasons(String jsonData) {
		// Parse JSON data
		System.debug(jsonData);
		SeasonsData seasonsData = 
			(SeasonsData) JSON.deserializeStrict(jsonData, SeasonService.SeasonsData.class);

		// Construct a Unit Of Work to capture the follow working
		fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

		Map<String, Driver__c> driversById = new Map<String, Driver__c>();
		for(DriverData driverData : seasonsData.drivers) {
		    // Create Driver__c record
			Driver__c driver = new Driver__c(
				Name = driverData.name,
				DriverId__c = driverData.driverId,
				Nationality__c = driverData.nationality,
				TwitterHandle__c = driverData.twitterHandle,
				FIA_Super_License__c = driverData.fiaLicense,
				Active__c = driverData.active);
			uow.registerNew(driver);
			driversById.put(driver.DriverId__c, driver);
		}
		Map<String, Team__c> teamsById = new Map<String, Team__c>();
		for(TeamData teamData : seasonsData.teams) {
			// Create Team__c record
			Team__c team = new Team__c(
				Name = teamData.name,
				Nationality__c = teamData.nationality,
				Home_Base__c = teamData.nationality,
				Active_Since__c = teamData.activeSince,
				Team_Boss__c = teamData.teamBoss,
				Team_Id__c = teamData.teamId
			);
			uow.registerNew(team);
			teamsById.put(team.Team_Id__c, team);
		}
		for(SeasonData seasonData : seasonsData.seasons) {
			// Create Season__c record
			Season__c season = new Season__c(
				Name = seasonData.year,
				Year__c = seasonData.year);
			uow.registerNew(season);
			for(RaceData raceData : seasonData.races) {
				// Create Race__c record
				Race__c race = new Race__c(
					Name = raceData.name,
					Round__c = raceData.round,
					Status__c = raceData.status,
					Race_Date__c = raceData.raceDate
					);				
				uow.registerNew(race, Race__c.Season__c, season);
				for(ContestantData contestantData : raceData.contestants) {
					// Create Contestant__c record
					Contestant__c contestant = new Contestant__c(
							Car_Number__c = contestantData.carNumber,
							Laps_Completed__c = Integer.valueOf(contestantData.lapsCompleted),
							ChampionshipPoints__c = contestantData.championshipPoints,
							DNF__c = contestantData.dnf,
							RacePosition__c = contestantData.racePosition,													
							Qualification1LapTime__c = contestantData.qualification1LapTime,
							Qualification2LapTime__c = contestantData.qualification2LapTime,
							Qualification3LapTime__c = contestantData.qualification3LapTime);
					uow.registerNew(contestant, Contestant__c.Race__c, race);
					uow.registerRelationship(contestant, 
						Contestant__c.Driver__c, driversById.get(contestantData.driverId));
					uow.registerRelationship(contestant, 
						Contestant__c.Team__c, teamsById.get(contestantData.teamId));
				}
			}
		}
		// Insert records registered with uow above
		uow.commitWork();
	}

	public class UpdateStandings {
		public Id seasonId;
		public Boolean issueNewsLetter;

	}

	public class SeasonsData {
		public List<DriverData> drivers;
		public List<TeamData> teams;
		public List<SeasonData> seasons;
	}

	public class DriverData {
		public String name;
		public String nationality;
		public String driverId;		
		public String twitterHandle;
		public Boolean fiaLicense;
		public Boolean active;		

	}

	public class TeamData {
		public string name;
		public string nationality;
		public string homeBase;
		public string activeSince;
		public string teamBoss;
		public string teamId;
	}

	public class SeasonData {
		public String year;
		public List<RaceData> races;
	}

	public class RaceData {
		public Integer round;
		public String name;
		public List<ContestantData> contestants;
	}

	public class ContestantData {
		public String driverId;
		public String teamId;
		public String carNumber;
		public String lapsCompleted;
		public Integer championshipPoints;
		public Boolean dnf;
		public Integer racePosition;
		public Integer qualification1LapTime;
		public Integer qualification2LapTime;
		public Integer qualification3LapTime;
	}

}