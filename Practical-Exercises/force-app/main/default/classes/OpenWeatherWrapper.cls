public with sharing class OpenWeatherWrapper {
   
    public class Weather {
        public Integer id {get; set;}
        public String main {get; set;}
        public String description {get; set;}
        public String icon {get; set;}
    }

    public class Coord {
        public Double lon {get; set;}
        public Double lat {get; set;}
    }

    public class Wind {
        public Double speed {get; set;}
        public Integer deg {get; set;}
        public Double gust {get; set;}
    }

    public class Clouds {
        public Integer all {get; set;}
    }

    public class Sys {
        public Integer type {get; set;}
        public Integer id {get; set;} 
		public String country {get; set;} 
		public Integer sunrise {get; set;} 
		public Integer sunset {get; set;} 
    }

    public class Main {
        public Double temp {get; set;}
        public Double feels_like {get; set;} 
		public Double temp_min {get; set;} 
		public Double temp_max {get; set;} 
		public Integer pressure {get; set;} 
		public Integer humidity {get; set;} 
		public Integer sea_level {get; set;} 
		public Integer grnd_level {get; set;} 
    }

    public Coord coord {get; set;} 
	public List<Weather> weather {get; set;} 
	public String base {get; set;} 
	public Main main {get; set;} 
	public Integer visibility {get; set;} 
	public Wind wind {get; set;} 
	public Clouds clouds {get; set;} 
	public Integer dt {get; set;} 
	public Sys sys {get; set;} 
	public Integer timezone {get; set;} 
	public Integer id {get; set;} 
	public String name {get; set;} 
	public Integer cod {get; set;} 


    // public static OpenWeatherWrapper parse (String json) {
    //     System.JsonParser parser = System.Json.createParser(json);
    //     return new OpenWeatherWrapper(json);
    // }
}