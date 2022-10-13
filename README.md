# Project 2: Shiny App Development

### [Project Description](doc/project2_desc.md)

![screenshot](doc/figs/arrest.png)



## Project: NYPD Arrest Activities
Term: Fall 2022

+ Team # Group 10
+ **Crime Data Shiny app**:
	+ Cheng, Louis
	+ Li, Shuangxian
	+ Wang, Yayuan
	+ Wislicki, Tomasz

+ shiny link:

+ **Project summary**:
In New York, there are many criminals who are not arrested, which make the citizens and tourists very afraid. Besides, NYC government is committed to keep NYC safe enough for residents and tourists.

Utilizing the arrest data provided by NYPD, this application aims to provide insight into the public security and police enforcement activities in New York from January 2011 to June 2022. The application includes one map, a time series plot, and pie charts to further break down the arrest activities into the perpetrators' gender, age, race, and the location of the arrest event.

Our users are government ,policemen,local residents and tourists. Through our app, residents and tourists can find different types of arrested criminals for every year and borough. It means people can keep away from some dangerous locations since we can find when and where criminals appeared possibly in the past 10 years using the app. The government can study how much the arrests affected  by different factors(age, gender, race, covid-19, borough) and determine how to change the situation.In addition, the police can predict when and where various criminals will appear. This can help them arrest criminals quickly.


+ **Contribution statement**: 

Yayuan and Shuangxian chose the dataset and the topic.

Shuangxian constructed the frame of the application page and designed the time series tab and pie chart tab.

Yayuan created and wrote up the Home and Appendix page and designed the map tab. 

Shuangxian and Yayuan helped polish and improve the visualizations for each other.

Tomasz and Louis designed the radar chart and integrated it in the UI. Both worked together to polish the visualizations and description for Home page.

Louis rearranged and organised the repo, resolving conflicts between files.

+ **Data source**: 
NYC Open Data:  
   + https://data.cityofnewyork.us/Public-Safety/NYPD-Arrests-Data-Historic-/8h9b-rp9u/data
   + https://data.cityofnewyork.us/Public-Safety/NYPD-Arrest-Data-Year-to-Date-/uip8-fykc

Following [suggestions](http://nicercode.github.io/blog/2013-04-05-projects/) by [RICH FITZJOHN](http://nicercode.github.io/about/#Team) (@richfitz). This folder is orgarnized as follows.

```
proj/
├── app/
├── lib/
├── data/
├── doc/
└── output/
```

Please see each subfolder for a README file.

