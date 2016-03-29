# Youth Match
_Automating a lottery which matches local young people to meaningful (summer) employment, and tracking their responses._

[![Build Status](https://travis-ci.org/MAPC/youth_match.svg?branch=develop)](https://travis-ci.org/MAPC/youth_match)
[![Code Climate](https://codeclimate.com/github/MAPC/youth_match/badges/gpa.svg)](https://codeclimate.com/github/MAPC/youth_match)
[![Test Coverage](https://codeclimate.com/github/MAPC/youth_match/badges/coverage.svg)](https://codeclimate.com/github/MAPC/youth_match/coverage)
[![Inline docs](http://inch-ci.org/github/MAPC/youth_match.png)](http://inch-ci.org/github/MAPC/youth_match)

### The Challenge

The Division of Youth Engagement and Employment (DYEE), a division of Boston Centers for Youth and Families (BCYF), runs an annual summer jobs program that connects young people in Boston to meaningful summer employment.

The jobs program is administered in two stages.

1. __Direct application:__ Applicants apply directly to jobs at local community-based organizations (CBOs) through DYEE's summer jobs portal. Once the CBOs hire for all their positions, those who were hired are removed from the hiring pool.

2. __Lottery:__ Remaining applicants are entered into a lottery program, where they are semi-randomly matched to jobs. DYEE staff attempt to find jobs that are near the applicant, and ideally match one of the interests the young person listed on their job application.

To run the lottery (before implementation of this software), DYEE emails applicants in batches, asking everyone to call in to get placed into a job. Each call takes between 5 and 30 minutes, with an estimated total between 500-1500 hours to place applicants.

### The Solution

Youth Match addresses the Lottery part of the jobs program, with the goal of saving staff from making 80% of placement calls. Many young people will still need to be contacted by phone or other means, since not everyone has reliable access to the internet and email at home, at school, or at libraries, especially in areas with reduced funding for public services.

We listened to DYEE staff explain how they place applicants into position by phone. Staff look for a job relatively close to applicants' home location, looking it up by zip code, and try to find a job that matches the applicant's three stated interests, which they selected from a list when applying. Staff also take into account whether applicants prefer to work closer to home, or to find something that matches their interest, even if it's farther out. Staff also ask whether applicants have a transit pass.

We created a program that tries to follow the same logic. The general process follows.

1. Randomize applicants.
2. For each applicant, look up all the available jobs (not taken by another applicants) within a 40-minute range from the applicant's home location. If this applicant has stated in their application that they have a transit pass, we look up all the jobs accessible in a 40-minute transit commute. Otherwise, we look up jobs within a 40-minute walking commute.
3. For each job within an applicant's range, convert the travel time from their home to the job into a numeric score from -5 to +5. If an applicant has stated that they prefer working closer to home, we use an equation that gives shorter times a higher score, and longer times a much lower score.
4. For each job, we also calculate how well a job matches an applicant's stated interests.
5. Combine the two scores to get the overall match score, with a range of -10 to 10.
6. Select the best job for that applicant, with the highest score,8 and remove it from the pool.

##### After running the lottery.

1. After running the lottery multiple times, we use statistics about the run to select the best overall outcome.
2. Then, we export a mail merge sheet and email each applicant their offers, then set an expiration date an the offers.
3. Applicants have a chance to respond by email, by clicking on buttons saying 'Accept Offer' or 'Decline'. We'll call those who don't respond by email, and indicate their responses via web application on their behalf.
4. The response to the offer is relayed, via web application, to the hiring system API, to kick off the onboarding workflow for that hire. Applicants are then directed to the youth jobs program website for next steps.

##### How do we calculate travel times?

In order to limit the number of times we would need to call a Google Maps API (12,000,000 times per run, which would take rougly 120 days), we precalculated travel times into a grid.

In essence, we created a spatial database in which we sliced Boston into 250-meter grid cells, and calculated the travel time -- by both public transit and walking -- between every possible combination of grid cells.

Before running the lottery, we geocode the address of every applicant and job site, which means we convert it from a text address (`1483 Tremont Street, Roxbury MA`) into a latitude-longitude point location (`[42.3322441, -71.0982959]`). Next, we use the point to figure out which grid cell that applicant or job is in. Then, we use the applicant grid cell and the job grid cell to look up the travel time between the two.

More information will be available in the [Distance Matrix][dm] project, which we used to create the grid. We are [available to consult with you](mailto:mcloyd@mapc.org) on seting up your own transportation time grid and database.

[dm]: https://github.com/MAPC/youth_jobs_distance_matrix

### Important notes on implementation

Not every young person seeking a job will have reliable internet access or  access to a cell phone. Having a clear understanding of inequity is essential to the responsible implmentation of this software. Please continue to use Youth Match __ONLY__ if you clearly understand the following:

- __Youth Match will not eliminate the need to make phone calls to young people.__ In order to ensure that all applicants are contacted equitably, young people with limited internet and email access will need to be contacted by phone or other methods.

- __Youth Match will not eliminate or even necessarily reduce the spatial inequity inherently present in a random lottery. At the present time, we recommend placing applicants in low-opportunity areas into jobs by phone.__ There is often a significant difference in quantities of meaningful job opportunities between neighborhoods in metropolitan regions. Regardless of whether a job lottery is automated or manual, applicants in low-opportunity areas are likely to see a lower placement rate, which is true regardless of whether this software is used. That is, this pattern emerges in phone-based placement approaches as well. We are presently working to building greater equity considerations into Youth Match, but until that time, it will not sufficiently address spatial inequity.

- __Time "saved" from implementing Youth Match is not a valid reason to cut funding to a youth employment program.__ Youth Match is designed to divert staff time from making placement phone calls to doing outreach that provides more employment opportunities for young people. Until the youth employment rate is equal to the overall employment rate in an [MSA][msa], citing Youth Match as a reason for cutting funding to youth employment program budgets because it saves staff time directly contradicts the intent with which this software is developed.

[msa]: https://en.wikipedia.org/wiki/Metropolitan_statistical_area

### Getting Set Up

Are you interested in using or developing Youth Match? Welcome! We love it when people are interested in using our projects and help to make them better.

If you get stuck anywhere in this documentation, please [get in touch](mailto:mcloyd@mapc.org) to let us know so we can help. We want to create a smooth setup process, and need your help to identify where the sticking points are.

> __Note__

> The following setup instructions assume you are familiar with [the command line (i.e. Terminal), Git, Github][github], [PostgreSQL][postgresql], [PostGIS and spatial data or GIS concepts][postgis], [Ruby][ruby], and Rack-based Ruby web frameworks like [Rails][rails] or Sinatra.

> Links in the above line lead to helpful documentation, mostly written by Code for America and other civic tech communities, on how to get started with these tools/

> If you are not familiar with any of these tools or concepts, we encourage you to [seek people or communities who are][meetup]. Learning these, especially PostGIS and spatial concepts, can be [extraordinarily][lyzi1] [difficult][lyzi2] alone, and communities can be a major asset in accelerating your learning and answering questions.

1. Ensure you've set up:

- Ruby (2.1.5)
- PostgreSQL and PostGIS (this can be done via the [Postgres app](http://postgresapp.com/))

2. Clone the repository, `cd` into it, and `bundle install`.
3. Set up the database by running `rake db:create`, then `rake db:migrate`.

> Database tasks run differently than they do in Rails, because we're not using Rails as a framework. For example, you won't be able to chain commands like you can in Rails, such as `rake db:create db:migrate`. Read the database.rake file to see how the database tasks work.

4. Set up the test database by running `rake db:create DATABASE_ENV=test`, then `rake db:migrate DATABASE_ENV=test`
5. Ensure all tests are passing by running `rake test` or `rake`. (The test task is set to be the default Rake task.)

> You may see a number of noisy but harmless warnings before the tests start running. If anyone can address this, we welcome the contribution.

6. Test out the console by running `bin/console`. This script mimicks `rails console` -- it just loads the environment and starts IRB. To see if it works, try running `Applicant.new`. It should execute with no problems.
7. Test out the webserver by running `foreman start` and navigating to the address stated in the logs. This will boot up the Sinatra web application.

> __NOTE__: This Procfile, with the `rerun` command, is not suitable for production because `rerun` is a gem in the `:development` group.

[github]: https://18f.gsa.gov/2015/03/03/how-to-use-github-and-the-terminal-a-guide/
[ruby]: https://github.com/codeforamerica/howto/blob/master/Ruby.md
[rails]: https://github.com/codeforamerica/howto/blob/master/Rails.md
[postgresql]: https://github.com/codeforamerica/howto/blob/master/PostgreSQL.md
[postgis]: http://workshops.boundlessgeo.com/postgis-intro/
[meetup]: http://www.meetup.com/find/events/?allMeetups=false&keywords=spatial&radius=10&userFreeform=Cambridge%2C+MA&mcId=z2139&mcName=Cambridge%2C+MA&eventFilter=mysugg
[lyzi1]: http://lyzidiamond.com/posts/what-to-learn-first
[lyzi2]: http://lyzidiamond.com/posts/what-to-learn-first-pt-2


#### Preparing Your Data

> TODO

#### Importing Your Data

> TODO

### Lottery web interface

Run `foreman start` to start the web application with environment variables stored in .env, or `ruby app.rb` to start the web interface for the runs.

### Relay web application

> TODO

### Running the Lottery

The lottery is run via a set of rake tasks, collected in `lottery.rake`. The main task is `lottery:run`. This first invokes `lottery:check` to ensure the database is set up correctly, though this is more a sanity check than a thorough one. Then, it runs the MatchJob class, which is responsible for doing the work of matching. Once MatchJob has finished -- either from running out of available positions or applicants -- `lottery:stats` is invoked, which generates statistics on how well that run went, and what the overall outcomes are.

We recommend running the lottery multiple times, because the random order in which applicants are matched to a job may affect the overall outcome of the matching process. We generate statistics on placement rate, satisfaction rate (how many people were matched with a job that aligns with their preferences), and travel time breakdown, in order to compare multiple runs and choose the best one to move forward with.

#### Options for running the lottery

##### Sequentially

If you've got the time, you can run mutliple runs in a row, one after the other.

```ruby
  3.times { system 'foreman run rake lottery:run' }
```

##### Concurrently (Terminal)

Since each run happens independently, with its own context, multiple lotteries can be run at once. We haven't tested whether this is faster, and it may require both JRuby and multi-core processors to see a difference in execution time, but it frees your console up to do other things more quickly. Plus, [learning about threads can be fun][thread].

You can run the task in threads using a script like this.

```ruby
3.times do |i|
  Thread.new do
    system 'foreman run rake lottery:run'
  end
end
```

[thread]: https://www.agileplannerapp.com/blog/building-agile-planner/rails-background-jobs-in-threads

##### Concurrently (Container)

If you have a service like Docker Cloud set up, you can build a Docker image using the provided Dockerfile, and scaling your containers to the maximum. Make sure to set the command to `rake lottery:run`, and to set your environment variables -- especially the `DATABASE_URL`, in this case, before scaling.

You may need to change the command sent to `system` depending on your environment setup.

> __TIP__: If you do not already have Docker Cloud or container hosting set up, it is likely not worth your time to do so for this project.

### What happens after running the lottery?

We recommend running the lottery multiple times, in order to have several runs to compare.

Once you have selected the best run, we recommend deleting the runs you don't plan to use.

Export the mail merge sheet (TODO / feature not yet available). We'll provide a mail merge email template in this repository once we've developed one of our own.

### Roadmap

- __API Import__ to idempotently load live data from hiring system APIs, while being efficient about calls to duck rate limits by a wide margin.
- __Improved Batching__ to facilitate experiments that test the validity of a technology-based approach to the youth job lottery.
- __In-browser mail merge export__, to download applicant sheets and call lists.
- __Standard mail merge template__ for properly formattng links, etc.
- __Relay application__ to handle responses from applicants about whether they accept or decline their summer job offer and coordinate with the City's hiring system.
- __Vicarious applicant interface__, to allow staff members who are calling applicants with limited internet/email access to respond to an automatic placement offer on the applicant's behalf.
- __Configuration for redeployment__ so that other cities can use this project without having to significantly change the codebase.

### Contact

This project is actively maintained by the Metropolitan Area Planning Council.

Contact Matt Cloyd, Developer & Product Manager at mcloyd@mapc.org.


### Credits

This project is funded by the Civic Technology and Data Collaborative grant, provided by [Living Cities][lc], [Code for America][cfa], and the [National Neighborhood Indicators Partnership][nnip], with matching support from [BNY Mellon][bny].

[lc]: https://www.livingcities.org/
[cfa]: https://codeforamerica.org
[nnip]: http://www.neighborhoodindicators.org/
[bny]: https://www.bnymellon.com/

### Contributing

We strongly encourage contributions -- we believe that your code can make this project better!

Get in touch by filing an issue, submitting a pull request, or emailing us.
