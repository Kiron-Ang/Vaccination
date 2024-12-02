install.packages('rsconnect')

library(rsconnect)

rsconnect::setAccountInfo(name='8zjn1m-kiron-ang',
			  token='46463AFD78EE58FC283684112E29743A',
			  secret='PiPkguwuGNN3quPEiQKnNJSYiuVoyqhi1f96hUSA')

rsconnect::deployApp()