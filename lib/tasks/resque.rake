require "resque"
require "resque/tasks"
require "resque/scheduler/tasks"
require "./config/application"

namespace :resque do
  task setup_schedule: :setup do
    require "resque-scheduler"
    Resque.schedule = YAML.load_file("./config/resque_scheduled_jobs.yml")
  end

  task scheduler: :setup_schedule
end
