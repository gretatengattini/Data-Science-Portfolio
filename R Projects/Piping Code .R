##### MULTIPLE OBJECTS 
install.packages("magrittr")
install.packages("dplyr")
library(magrittr)
library(dplyr)

print(mtcars)
a <- filter(mtcars, carb > 2)
b <- group_by(a, cyl)
c <- summarise(b, avg_mpg=mean(mpg))
d <- filter(c, avg_mpg > 15)

### NESTED OBJECTS
z <- filter(
summarise(
group_by(
filter(
  mtcars, carb > 2
      )
  ,cyl
       ),
avg_mpg = mean(mpg)
),
avg_mpg > 15
)

### PIPING METHOD

piped_df <- mtcars %>%
  filter(carb > 2) %>%
  group_by(cyl) %>%
  summarise(avg_mpg = mean(mpg)) %>%
  filter(avg_mpg > 15)





