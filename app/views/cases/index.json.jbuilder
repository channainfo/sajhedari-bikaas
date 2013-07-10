json.array!(@cases) do |case|
  json.extract! case, :message, :conflict_type_id, :conflict_intensity_id, :conflict_state_id, :location_id, :user_id, :site_id
  json.url case_url(case, format: :json)
end
