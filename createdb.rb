# Set up for the application and database. DO NOT CHANGE. #############################
require "sequel"                                                                      #
connection_string = ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/development.sqlite3"  #
DB = Sequel.connect(connection_string)                                                #
#######################################################################################

# Database schema - this should reflect your domain model
DB.create_table! :places do
  primary_key :id
  String :city
  String :description, text: true
  String :population
  String :fun_fact
  String :image
end
DB.create_table! :activities do
  primary_key :id
  foreign_key :places_id
  foreign_key :user_id
  String :title
  String :description, text: true
  String :type
  
end
DB.create_table! :votes do
  primary_key :id
  foreign_key :places_id
  foreign_key :activities_id
  foreign_key :user_id
  Integer :votes
  
end
DB.create_table! :users do
  primary_key :id
  String :name
  String :email
  String :password
end

# Insert initial (seed) data
places_table = DB.from(:places)

places_table.insert(city: "Toronto, ON", 
                    description: "Toronto is the provincial capital of Ontario and the most populous city in Canada, with a population of 2,954,024 as of July 2018. The city is the anchor of the Golden Horseshoe, an urban agglomeration of 9,245,438 people (as of 2016) surrounding the western end of Lake Ontario. Toronto is an international centre of business, finance, arts, and culture, and is recognized as one of the most multicultural and cosmopolitan cities in the world.",
                    population:"2.9 million",
                    fun_fact: "The Rogers Centre is the first stadium in the world to have a fully retractable roof.",
                    image: "images/toronto.jpg")

places_table.insert(city: "Chicago, IL", 
                    description: "Chicago is the most populous city in the U.S. state of Illinois, and the third-most-populous city in the United States. With an estimated population of 2,705,994 (2018), it is also the most populous city in the Midwestern United States. Located on the shores of freshwater Lake Michigan, Chicago was incorporated as a city in 1837 near a portage between the Great Lakes and the Mississippi River watershed and grew rapidly in the mid-19th century. After the Great Chicago Fire of 1871, which destroyed several square miles and left more than 100,000 homeless, the city made a concerted effort to rebuild.",
                    population:"2.8 million",
                    fun_fact: "Dark Knight's climax was filmed at the Trump tower (when it was under construction)!!",
                    image: "images/chicago.jpg")

places_table.insert(city: "New York, NY", 
                    description: "The City of New York, is the most populous city in the United States. With an estimated 2018 population of 8,398,748 distributed over about 302.6 square miles. New York City has been described as the cultural, financial, and media capital of the world, significantly influencing commerce, entertainment, research, technology, education, politics, tourism, art, fashion, and sports. Home to the headquarters of the United Nations, New York is an important center for international diplomacy.",
                    population:"8.4 million",
                    fun_fact: "900 fashion companies are headquartered in NYC.",
                    image: "images/newyork.jpg")

places_table.insert(city: "Los Angeles, CA", 
                    description: "Los Angeles, often known by its initials L.A., is the most populous city in California; the second most populous city in the United States, after New York City; and the third most populous city in North America, after Mexico City and New York City. With an estimated population of nearly four million people, Los Angeles is the cultural, financial, and commercial center of Southern California. The city is known for its Mediterranean climate, ethnic diversity, the entertainment industry, and its sprawling metropolis.",
                    population:"3.7 million",
                    fun_fact: "There are 841 museums and art galleries in Los Angeles County. In fact, Los Angeles has more museums per capita than any other city in the world.",
                    image: "images/losangeles.jpg")