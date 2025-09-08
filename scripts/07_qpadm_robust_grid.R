suppressPackageStartupMessages(library(admixtools))
prefix <- "merged_1240k"
qpfun  <- get(if ("qpadm" %in% ls("package:admixtools")) "qpadm" else "qpAdm",
              asNamespace("admixtools"))

inds <- read.table(paste0(prefix,".ind"), stringsAsFactors=FALSE,
                   col.names=c("ind","sex","label"))
labs <- unique(inds$label)
jomon <- "Japan_Honshu_EarlyJomon.SG"; stopifnot(jomon %in% labs)

RIGHTS <- list(
  A = intersect(c("Mbuti.DG","Russia_UstIshim_IUP.DG","Russia_Kostenki14_UP.SG",
                  "Russia_MA1_UP.SG","India_GreatAndaman_100BP.SG",
                  "Papuan.DG","Italy_Epigravettian.AG","Belgium_GoyetQ116_1_UP.AG","Karitiana.DG"), labs),
  C = intersect(c("Mbuti.DG","Russia_UstIshim_IUP.DG","Russia_Kostenki14_UP.SG",
                  "Russia_MA1_UP.SG","Karitiana.DG","Papuan.DG"), labs)
)
partners <- intersect(c("Korean.DG","Han.DG","CHB.DG"), labs)

run_one <- function(partner, right, tag){
  out <- try(qpfun(data=prefix, target="me",
                   left=c(jomon, partner), right=right,
                   allsnps=TRUE, verbose=FALSE), silent=TRUE)
  if (inherits(out,"try-error")) return(NULL)
  w <- subset(out$weights, left==jomon)
  data.frame(NEA=partner, RIGHT=tag, allsnps=TRUE,
             jomon=w$weight, se=w$se,
             ciL=pmax(0, w$weight-1.96*w$se),
             ciU=pmin(1, w$weight+1.96*w$se))
}

res <- do.call(rbind, c(
  lapply(partners, \(p) run_one(p, RIGHTS$A, "A")),
  lapply(partners, \(p) run_one(p, RIGHTS$C, "C"))
))
res <- res[!sapply(res, is.null), ]

write.csv(res, "qpadm_jomon_robust_grid_raw.csv", row.names=FALSE)

res_clean <- subset(res, se < 0.2 & jomon > -0.2 & jomon < 0.5)
write.csv(res_clean, "qpadm_jomon_robust_grid_clean.csv", row.names=FALSE)

agg <- aggregate(cbind(jomon,se,ciL,ciU)~NEA, data=res_clean,
                 FUN=function(x) c(median=median(x,na.rm=TRUE)))
write.csv(agg, "qpadm_jomon_robust_summary.csv", row.names=FALSE)

# プロット（棒＋誤差）
png("qpadm_jomon_robust_bar.png", 900, 500, res=120)
op <- par(mar=c(7,4,2,1))
labs_bar <- paste(res_clean$NEA, res_clean$RIGHT, sep="\n")
ylim_top <- max(20, 100*max(res_clean$ciU, na.rm=TRUE))
bx <- barplot(res_clean$jomon*100, names.arg=labs_bar, las=2,
              col="#95a5a6", ylab="% Jomon (qpAdm weight)", ylim=c(0,ylim_top))
arrows(bx, res_clean$ciL*100, bx, res_clean$ciU*100, angle=90, code=3, length=0.03)
abline(h=0, col="#666")
par(op); dev.off()
