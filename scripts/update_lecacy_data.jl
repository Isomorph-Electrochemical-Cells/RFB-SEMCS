using SEMCS

function update_lecacy_data()
    geometry = "square_array_disk_2d"
    df = read_data("data/" * geometry * "/vam_lecacy.csv")
    preprocess_legacy_data!(df)
    write_data("data/" * geometry * "/vam.csv", df)
end

update_lecacy_data()
