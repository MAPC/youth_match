namespace :export do

  desc 'Export placements for mail merge'
  task :mailmerge, [:run_id] => [:environment] do |task, args|
    MailMergeExporter.new(args[:run_id]).perform!
  end

  desc 'Export positions'
  task positions: :environment do |task, args|
    pre_message task
    file = "./tmp/exports/positions-#{Time.now.to_i}.csv"
    CSV.open(file, 'wb') do |csv|
      fields = %w( uuid category positions manual automatic street city state zip zip_5 )
      csv << fields # Header
      Position.find_each do |position|
        csv << fields.map { |field| position.send(field) }
      end
    end
  end

  namespace :manual do
    desc 'Export applicants with a manual market'
    task applicants: :environment do |task, args|
      pre_message task
      file = "./tmp/exports/manual-applicants-#{Time.now.to_i}.csv"
      CSV.open(file, 'wb') do |csv|
        csv << ['id']
        Applicant.where(market: :manual).find_each {|o| csv << [o.id] }
      end
    end

    desc 'Export positions with a manual market'
    task positions: :environment do |task, args|
      pre_message task
      raise ArgumentError if Position.where(manual: nil).count > 0
      file = "./tmp/exports/manual-positions-#{Time.now.to_i}.csv"
      CSV.open(file, 'wb') do |csv|
        csv << ['id']
        Position.find_each do |o|
          o.manual.times { csv << [o.id] } # One row per manual position
        end
      end
    end
  end

  namespace :geojson do
    desc 'Export a GeoJSON file with all positions, placements, and applicants.'
    task :all, [:run_id] => [:environment] do |task, args|
      GeoJSONExporter.new(run_id: args[:run_id]).perform
    end

    desc 'Export applicant points as GeoJSON'
    task :applicants, [:run_id] => [:environment] do |task, args|
      GeoJSONExporter.new(run_id: args[:run_id], layers: [:applicants]).perform
    end

    desc 'Export position points as GeoJSON'
    task :positions, [:run_id] => [:environment] do |task, args|
      GeoJSONExporter.new(run_id: args[:run_id], layers: [:positions]).perform
    end

    desc 'Export placement lines as GeoJSON'
    task :placements, [:run_id] => [:environment] do |task, args|
      GeoJSONExporter.new(run_id: args[:run_id], layers: [:placements]).perform
    end

    desc 'Export applicants, points, and placements as separate GeoJSON files'
    task :each, [:run_id] => [:environment] do |task, args|
      [:applicants, :positions, :placements].each do |layer|
        geo = GeoJSONExporter.new(layers: [layer])
        geo.generate
        geo.to_file
      end
    end
  end

end
