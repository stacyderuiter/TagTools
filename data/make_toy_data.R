#make tiny toy datasets
beaked_whale <- load_nc('testset1.nc')

for (s in 1:3){
  df=25
  beaked_whale[[s]]$data <- decdc(beaked_whale[[s]]$data, df)
  beaked_whale[[s]]$sampling_rate <- beaked_whale[[s]]$sampling_rate/df
}

save(beaked_whale, file='beaked_whale.Rdata')

harbor_seal <- load_nc('testset2.nc')

st <- 0.4*3600*harbor_seal[[1]]$sampling_rate
et <- st + 0.3*3600*harbor_seal[[1]]$sampling_rate
for (s in 1:3){
  if (length(dim(harbor_seal[[s]]$data))==2){
    harbor_seal[[s]]$data <- harbor_seal[[s]]$data[st:et,]
  }
  if (length(dim(harbor_seal[[s]]$data))==1){
    harbor_seal[[s]]$data <- harbor_seal[[s]]$data[st:et]
  }
}


save(harbor_seal, file='harbor_seal.Rdata')

sperm_whale <- load_nc('testset3.nc')
for (s in 1:3){
  df=25
  sperm_whale[[s]]$data <- decdc(sperm_whale[[s]]$data, df)
  sperm_whale[[s]]$sampling_rate <- sperm_whale[[s]]$sampling_rate/df
}

save(sperm_whale, file='sperm_whale.Rdata')