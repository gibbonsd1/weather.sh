# weather.sh

weather.sh is a small bash script that outputs weather data for a city directly in your terminal. It uses wget. sed and awk mostly. Weather data comes from weather.com.

  * Author : Laurier Rochon
  * Website : pwd.io

##Installation

    wget --quiet https://raw.github.com/l-r/weather.sh/master/weather.sh && \
    chmod +x weather.sh && \
    alias weather=./weather.sh


##Valid usage examples

 Basic syntax : **weather** ```city\_name``` \(```state/province```\) ```country\_code```

  * ````weather montreal qc ca````
  * ````weather amsterdam nl````
  * ```weather "new york"```
  * ```weather "cape town" ZA```

If all goes well, response will be as follows :

  * ```It's currently -17°C (°F), in Cape Town ZA.```

If multiple options are available for the given input, such choices will appear : 

    Did you mean:
    1) 'New York, NY, US'       5) 'New York,  MX'
    2) 'West New York, NJ, US'   6) 'New York, I9, GB'
    3) 'New York Mills, MN, US'  7) None, make a new search
    4) 'New York Mills, NY, US'
    #? 
