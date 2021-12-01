# frozen_string_literal: true

require 'json'

class Sessions
  file = File.read('./data.json')
  data = JSON.parse(file, object_class: OpenStruct)
  events = data.events
  sorted_events = events.sort { |e1, e2| e1.timestamp - e2.timestamp }

  sessions = {}
  users = sorted_events.map { |event| event['visitorId'] }.uniq
  users.each do |user|
    sessions[user] = sorted_events.chunk_while { |e1, e2| e2['timestamp'] - e1['timestamp'] <= 600_000 }
  end

  sessions_by_user = {}

  users.each do |user|
    formatted_sessions = []

    sessions[user].each do |session|
      duration = session[-1]['timestamp'] - session[0]['timestamp']
      pages = session.map { |event| event['url'] }
      starttime = session[0]['timestamp']

      formatted_session = {
        'duration' => duration,
        'pages' => pages,
        'startTime' => starttime
      }
      formatted_sessions << formatted_session
    end
    sessions_by_user[user] = formatted_sessions
  end
  { 'sessionsByUser' => sessions_by_user }
  puts sessions_by_user
end
