suppressPackageStartupMessages(library(admixtools))
prefix <- "merged_1240k"
qpfun  <- get(if ("qpadm" %in% ls("package:admixtools")) "qpadm" else "qpAdm",
              asNamespace("admixtools"))

inds <- read.table(paste0(prefix,".ind"), stringsAsFactors=FALSE,
                   col.names=c("ind","sex","label"))
labs <- unique(inds$label)

jomon <- "Japan_Honshu_EarlyJomon.SG"; stopifnot(jomon %in% labs)
nea_set <- intersect(c("Russia_Boisman_MN.AG","China_AmurRiver_EarlyN.AG",
                        "China_AmurRiver_N.AG","China_AmurRiver_Mesolithic.AG"), labs)

kofun_auto <- labs[grepl("Japan_.*Kofun", labs, ignore.case=TRUE)]
ea_set <- unique(c(intersect(c("CHB.DG","Han.DG","CHB.SG","Han.SG"), labs), kofun_auto))
stopifnot(length(nea_set)>0, length(ea_set)>0)

RIGHTS <- list(
  A = intersect(c("Mbuti.DG","Russia_UstIshim_IUP.DG","Russia_Kostenki14_UP.SG",
                  "Russia_MA1_UP.SG","India_GreatAndaman_100BP.SG",
                  "Papuan.DG","Italy_Epigravettian.AG",
                  "Belgium_GoyetQ116_1_UP.AG","Karitiana.DG"), labs),
  C = intersect(c("Mbuti.DG","Russia_UstIshim_IUP.DG","Russia_Kostenki14_UP.SG",
                  "Russia_MA1_UP.SG","Karitiana.DG","Papuan.DG"), labs)
)
RIGHTS <- RIGHTS[sapply(RIGHTS,length)>=5]

run3 <- function(nea, ea, right, tag){
  out <- try(qpfun(data=prefix, target="me",
                   left=c(jomon, nea, ea), right=right,
                   constrained=TRUE, allsnps=FALSE, fudge=1e-3, blgsize=0.10,
                   verbose=FALSE), silent=TRUE)
  if (inherits(out,"try-error")) return(NULL)
  w  <- out$weights; rd <- out$rankdrop
  p  <- if (!is.null(rd) && nrow(rd)>0) rd$p[1] else NA_real_
  data.frame(NEA=nea, EA=ea, RIGHT=tag, p=p,
             Jomon=subset(w,left==jomon)$weight,
             NEA_w=subset(w,left==nea)$weight,
             EA_w=subset(w,left==ea)$weight,
             Jomon_se=subset(w,left==jomon)$se,
             NEA_se=subset(w,left==nea)$se,
             EA_se=subset(w,left==ea)$se)
}

grid <- list()
for (tag in names(RIGHTS)){
  r <- RIGHTS[[tag]]
  for (n in nea_set) for (e in ea_set) grid <- append(grid, list(run3(n,e,r,tag)))
}
grid <- do.call(rbind, Filter(Negate(is.null), grid))
grid$ciL <- pmax(0, grid$Jomon - 1.96*grid$Jomon_se)
grid$ciU <- pmin(1, grid$Jomon + 1.96*grid$Jomon_se)
grid <- grid[order(-grid$p, grid$RIGHT, grid$NEA, grid$EA), ]
write.csv(grid, "qpadm_3way_Jomon_Yayoi_Kofun_grid.csv", row.names=FALSE)
cat("Top 5 by p:\n"); print(head(grid,5), digits=3)

# ベスト可視化
best <- grid[1,]
rbest <- RIGHTS[[best$RIGHT]]
outb  <- qpfun(data=prefix, target="me",
               left=c(jomon, best$NEA, best$EA), right=rbest,
               constrained=TRUE, allsnps=FALSE, fudge=1e-3, blgsize=0.10,
               verbose=TRUE)
w <- setNames(outb$weights$weight, outb$weights$left)
png("qpadm_3way_best_pie.png", 720, 480, res=120)
pie(c(Jomon=w[jomon], Yayoi_NEA=w[best$NEA], Kofun_EA=w[best$EA]),
    col=c("#f39c12","#27ae60","#2980b9"),
    main=sprintf("3-way Best (p=%.3f)\nNEA=%s  EA=%s", best$p, best$NEA, best$EA))
dev.off()

png("qpadm_3way_best_bar.png", 720, 480, res=120)
vals <- c(Jomon=w[jomon], Yayoi_NEA=w[best$NEA], Kofun_EA=w[best$EA])
ses  <- c(outb$weights$se[outb$weights$left==jomon],
          outb$weights$se[outb$weights$left==best$NEA],
          outb$weights$se[outb$weights$left==best$EA])
bp <- barplot(vals*100, ylim=c(0,100),
              col=c("#f39c12","#27ae60","#2980b9"),
              ylab="% ancestry", main="qpAdm 3-way (constrained)")
arrows(bp, pmax(0, (vals-1.96*ses))*100,
           bp, pmin(1, (vals+1.96*ses))*100,
       angle=90, code=3, length=0.05)
dev.off()
