import matplotlib.pyplot as plt

# ----------------------------
# Data (lat, lon)
# ----------------------------
lakes = {
    "Windermere": (54.37870, -2.90580),
    "Ullswater": (54.57107, -2.86242),
    "Derwentwater": (54.58330, -3.15000),
    "Coniston Water": (54.36908, -3.07265),
    "Bassenthwaite Lake": (54.65000, -3.21667),
    "Thirlmere": (54.56672, -3.05678),
    "Haweswater": (54.48933, -2.82014),
    "Ennerdale Water": (54.52510, -3.37719),
    "Wast Water": (54.43724, -3.34371),
    "Buttermere": (54.54339, -3.27979),
}

tube_stations = {
    "Oxford Circus": (51.51517, -0.14119),
    "Green Park": (51.50674, -0.14276),
    "Baker Street": (51.52224, -0.15708),
    "King's Cross St Pancras": (51.53057, -0.12399),
    "Waterloo": (51.50322, -0.11328),
    "Victoria": (51.49663, -0.14401),
    "London Bridge": (51.50535, -0.08483),
    "Canary Wharf": (51.50362, -0.01987),
    "Bank": (51.51340, -0.08906),
    "Paddington": (51.51518, -0.17554),
}

# ----------------------------
# Plot
# ----------------------------
plt.figure(figsize=(10, 8))

# Lakes
lake_lons = [lon for (lat, lon) in lakes.values()]
lake_lats = [lat for (lat, lon) in lakes.values()]
plt.scatter(lake_lons, lake_lats, label="Lake District lakes", alpha=0.9)

# Tube
tube_lons = [lon for (lat, lon) in tube_stations.values()]
tube_lats = [lat for (lat, lon) in tube_stations.values()]
plt.scatter(tube_lons, tube_lats, label="London Tube stations", alpha=0.9)

# Labels
def label_points(points_dict, every_n=1, fontsize=8, offset_x=0, offset_y=0):
    for i, (name, (lat, lon)) in enumerate(points_dict.items()):
        if i % every_n == 0:
            plt.text(lon + offset_x, lat + offset_y, name, fontsize=fontsize)

# Custom offsets for tube stations to spread labels apart
tube_label_offsets = {
    "Oxford Circus": (0.002, 0.002),
    "Green Park": (-0.003, -0.001),
    "Baker Street": (-0.005, 0.003),
    "King's Cross St Pancras": (0.004, 0.002),
    "Waterloo": (0.001, -0.003),
    "Victoria": (-0.004, -0.003),
    "London Bridge": (0.005, 0.0),
    "Canary Wharf": (0.003, -0.002),
    "Bank": (0.0, 0.003),
    "Paddington": (-0.006, 0.001),
}

# Label lakes normally
label_points(lakes, every_n=1, fontsize=8)

# Label tube stations with custom offsets to avoid overlap
for name, (lat, lon) in tube_stations.items():
    offset_x, offset_y = tube_label_offsets.get(name, (0, 0))
    plt.text(lon + offset_x, lat + offset_y, name, fontsize=8)

# Axes, title, etc.
plt.xlabel("Longitude (X)")
plt.ylabel("Latitude (Y)")
plt.title("UK Places as Points (Map-like) — Two 'Semantic' Clusters")
plt.grid(True, alpha=0.25)
plt.legend()
plt.tight_layout()
plt.show()
