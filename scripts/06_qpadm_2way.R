suppressPackageStartupMessages(library(admixtools))
prefix <- "merged_1240k"
qpfun  <- get(if ("qpadm" %in% ls("package:admixtools")) "qpadm" else "qpAdm",
              asNamespace("admixtools"))

inds <- read.table(paste0(prefix,".ind"), stringsAsFactors=FALSE,
                   col.names=c("ind","sex","label"))
labs <- unique(inds$label)

jomon <- "Japan_Honshu_EarlyJomon.SG"
stopifnot(jomon %in% labs)

RIGHT_A <- intersect(c(
  "Mbuti.DG","Russia_UstIshim_IUP.DG","Russia_Kostenki14_UP.SG",
  "Russia_MA1_UP.SG","India_GreatAndaman_100BP.SG","Papuan.DG",
  "Italy_Epigravettian.AG","Belgium_GoyetQ116_1_UP.AG","Karitiana.DG"), labs)

two_way <- function(partner, tag){
  out <- qpfun(data=prefix, target="me",
               left=c(jomon, partner), right=RIGHT_A,
               allsnps=TRUE, verbose=TRUE)
  w <- out$weights
  ci <- within(w, {
    ciL <- pmax(0, weight - 1.96*se)
    ciU <- pmin(1, weight + 1.96*se)
  })
  write.csv(ci, sprintf("qpadm_2way_%s_weights_ci.csv", tag), row.names=FALSE)
  write.csv(out$rankdrop, sprintf("qpadm_2way_%s_rankdrop.csv", tag), row.names=FALSE)

  j <- subset(ci, left==jomon)$weight; j <- max(0, j)
  png(sprintf("qpadm_2way_%s_pie.png", tag), 600, 400, res=120)
  pie(c(Jomon=j, Non_Jomon=1-j), col=c("#f39c12","#bdc3c7"),
      main=sprintf("2-way (%s)\nJomon = %.1f%%", tag, 100*j))
  dev.off()
}

for (p in c("Korean.DG","CHB.DG","Han.DG")){
  if (p %in% labs) two_way(p, gsub("\\.DG|\\.SG","",p))
}
