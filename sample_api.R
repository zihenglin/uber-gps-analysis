library(rgdal)
library(sp)

# Load shapefile
tazs <- readOGR(dsn = "./tazs", layer = "mtc_taz1454_NAD83UTM10N_simple")

# Create a 2000 point random sample stratified w/in TAZs
samp <- spsample(tazs, "stratified", n = 2000)
samp.coords = samp@coords  # Note: this needs to be instantiated in the environment for some stupid R.eason

write.csv(samp.coords, file = './sample_out/sample_plan.csv')

# Uncomment to plot
# plot.new()
# plot(tazs)
# plot(sample)