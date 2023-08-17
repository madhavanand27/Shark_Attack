#Loading the library
library(tidyverse)
library(ggplot2)
library(lubridate)
library(billboarder)
library(plotly)
library(extrafont)

df <- read.csv("C:\\Users\\User\\OneDrive\\Desktop\\Business Analytics\\SQL\\GroupProject\\Cleaned_df.csv")
summary(df)

df$year <- as.numeric(df$year)
df <- df %>% filter(year != c(5,77,500))
summary(df$year)
#-------------------------------------------------------------------------------------------------------------
pie <- df %>% 
  group_by(type) %>% 
  summarize(number_of_time = n()) %>% 
  mutate(percentge = number_of_time / sum(number_of_time)*100)

billboarder() %>% 
  bb_piechart(pie) %>% 
  bb_title("Distribution of Types by their Count", )
#-------------------------------------------------------------------------------------------------------------
df %>% 
  group_by(country, fatal_yn) %>% 
  filter(fatal_yn == 'Y') %>% 
  summarise(count = n()) %>% 
  arrange(-count) %>% 
  head(10) %>% 
  ggplot(mapping = aes(x = reorder(country, -count), y = count))+
  geom_bar(stat = 'identity', fill = 'lightblue')+
  labs(title = "Top 10 Countries where People had Fatal Injury or have Found Dead.", 
       x = "Countries", y = "Number Of Cases")+
  theme(rect = element_blank(),
          axis.title = element_text(face = 'bold.italic'))
#-------------------------------------------------------------------------------------------------------------        
pie2<- df %>% 
  group_by(sex) %>% 
  summarize(count = n()) 

billboarder() %>% 
  bb_piechart(pie2) %>% 
  bb_title("Number of Cases by Gender")

#-------------------------------------------------------------------------------------------------------------
yes_fatal <-  read.csv("C:\\Users\\User\\Downloads\\yes_fatal.csv")
no_fatal <- read.csv("C:\\Users\\User\\Downloads\\no_fatal.csv")  

ggplotly(yes_fatal %>% 
  group_by(age_category) %>% 
  summarise(total = sum(number_of_observation)) %>% 
  filter(age_category != 'NULL') %>% 
  ggplot(aes(x = reorder(age_category, - total), y = total))+
  geom_bar(stat = 'identity', fill = 'black', color = 'black')+
  theme_bw() +
  labs(title = 'Number of Fatal Obseravtions by Age Category', 
       subtitle = 'The age category is grouped and categorized, it mutated from age column.',
       x = 'Age Category', y = 'Number of Observations'))
  
#-------------------------------------------------------------------------------------------------------------
ggplotly(no_fatal %>% 
  group_by(age_category) %>% 
  summarise(total = sum(number_of_observation)) %>% 
  filter(age_category != 'NULL') %>% 
  ggplot(aes(x = reorder(age_category, - total), y = total))+
  geom_bar(stat = 'identity', fill = 'white', color = 'black')+
  theme_bw() +
  labs(title = 'Number of Non-fatal Obseravtions by Age Category', 
       subtitle = 'The age category is grouped and categorized, it mutated from age column.',
       x = 'Age Category', y = 'Number of Observations'))

#-------------------------------------------------------------------------------------------------------------
data <- df %>% 
  filter(fatal_yn == 'Y') %>% 
  group_by(country, sex) %>% 
  summarize(number_of_deaths = n()) %>% 
  arrange(-number_of_deaths) 
 
data$country <- ifelse(data$country == 'Usa', 'USA', data$country)

  map <- map_data('world')
map <- rename(map, country = region)

main <- left_join(map, data, by = "country")

map_chart <- ggplot(main, aes(x = long, y = lat, group = group, label = country))+
  geom_polygon(aes(fill = number_of_deaths), color = 'black')+
  theme(rect = element_blank(),
        #legend.position = 'none',
        axis.title = element_blank(),
        axis.text = element_blank())+
  scale_fill_gradient(name = 'Number of Deaths',low = 'lightblue', high = 'red')+
  labs(title = "Number of Death by Countries", 
  caption = 'R Core Team (2023). _R: A Language and Environment for Statistical Computing_. R Foundation for
  Statistical Computing, Vienna, Austria. <https://www.R-project.org/>.')+
  theme(plot.title = element_text(hjust = 0.5, 
                                  size = , 
                                  face = 'bold'))
print(map_chart)


#-------------------------------------------------------------------------------------------------------------
yr <- read.csv("C:\\Users\\User\\Downloads\\year.csv")
str(yr)
yr$year <- as.character(yr$year)
font_import()

ggplot(yr, aes(x = year, y = reported_cases, fill = rank))+
  geom_bar(stat = 'identity', color = 'black')+
  scale_fill_gradient(low = 'black', high = 'white')+
  theme_minimal()+
  xlab('Year')+
  ylab('Reported Cases')+
  labs(title = 'Top 20 Years with the Most Reported Cases', 
       subtitle = 'The darker the bar is, the more rank it has.',
       caption = 'R Core Team (2023). _R: A Language and Environment for Statistical Computing_. R Foundation for
  Statistical Computing, Vienna, Austria. <https://www.R-project.org/>.')+
  theme(legend.position = 'none', 
        axis.title = element_text(face = 'bold.italic', size = 12),
        axis.text = element_text(face = 'bold'),
        plot.title = element_text(face = 'bold'))+
  geom_text(aes(label = reported_cases),
            position = position_dodge(width=0.9), 
            vjust = -0.25)

#-------------------------------------------------------------------------------------------------------------
df %>% filter(fatal_yn == 'Y') %>% 
  group_by(grouped_time, sex) %>% 
  summarise(number_of_attacks = n()) %>% 
  arrange(-number_of_attacks) %>% 
  filter(grouped_time != 'Not Recorded' & sex != 'not defined') %>% 
  mutate(percentage_distribution = round(number_of_attacks / sum(number_of_attacks) * 100, digits = 2)) %>% 
  ggplot(aes(x = grouped_time, y = number_of_attacks))+
  geom_bar(stat = 'identity', aes(fill = sex),  color = 'black')+
  theme(rect = element_blank())+
  labs(title = "Distribution of Data by Attack Time Devided by Gender", 
       x = "Attack Time", y = 'Number of Attacks', 
       caption = 'R Core Team (2023). _R: A Language and Environment for Statistical Computing_. R Foundation for
  Statistical Computing, Vienna, Austria. <https://www.R-project.org/>.')+
  theme_minimal()+
  scale_fill_manual(values = c("M" = "orange", "F" = "coral"))+
  theme(axis.title = element_text(size = 14, face = 'bold.italic'),
        axis.text = element_text(face = 'bold.italic'),
        plot.title = element_text(face = 'bold'))


#-------------------------------------------------------------------------------------------------------------

species_pie <- df %>% 
  filter(fatal_yn == 'Y') %>% 
  group_by(species) %>% 
  summarise(number_of_attempts = n()) %>% 
  arrange(-number_of_attempts) %>% filter(species != 'Unknown') %>% 
  top_n(4) 
billboarder() %>% 
  bb_piechart(species_pie) %>% 
  bb_title('Top 4 Species Having the Most Attempts', position = 'center')

#-------------------------------------------------------------------------------------------------------------
reporters <- read.csv("C:\\Users\\User\\Downloads\\rprts.csv")

ggplot(reporters, aes(investigator_or_source, active_investigators, fill = investigator_or_source ))+
  geom_bar(stat = 'identity', color = 'black')+
  geom_text(aes(label = active_investigators),
            position = position_dodge(width=0.9), 
            vjust = -0.25)+
  labs(title = 'Top Active Investigators',
       x = 'Investigators',
       y = 'Number of Investigations', caption = 'R Core Team (2023). _R: A Language and Environment for Statistical Computing_. R Foundation for
  Statistical Computing, Vienna, Austria. <https://www.R-project.org/>.')+
  theme_minimal()+
  theme(axis.title = element_text(face = 'bold.italic'),
        axis.text = element_text(face = 'bold.italic'),
        plot.title = element_text(face = 'bold', size = 16),
        legend.position = 'none')
