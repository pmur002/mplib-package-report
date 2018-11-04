
svg("diagram.svg")

library(grid)
library(metapost)
# library(gridBezier)

nr <- 12
nc <- 5
layout <- grid.layout(nr, nc)

grid.newpage()

pushViewport(viewport(width=.9, height=.9, layout=layout))

pushViewport(viewport(layout.pos.col=2:4, layout.pos.row=1:10))
grid.roundrect(r=unit(5, "mm"), gp=gpar(lty="dashed", fill="grey90"))
upViewport()

for (i in 1:nr) {
    for (j in 1:nc) {
        pushViewport(viewport(layout.pos.row=i, layout.pos.col=j,
                              gp=gpar(cex=.8),
                              name=paste("vp", i, j, sep=".")))
        upViewport()
    }
}

node <- function(label, row, col, name, font="mono", box=FALSE) {
    vp <- paste("vp", row, col, sep=".")
    if (box) {
        boxcol <- "black"
        boxfill <- "white"
    } else {
        boxcol <- "transparent"
        boxfill <- "transparent"
    }
    grid.roundrect(width=.8, height=unit(1.5, "lines"),
                   r=unit(1, "mm"), gp=gpar(col=boxcol, fill=boxfill),
                   name=paste0(name, "-box"), vp=vp)
    grid.text(label, gp=gpar(fontfamily=font), name=name, vp=vp)
}

arr <- arrow(angle=20, length=unit(2, "mm"), type="closed")

edge <- function(from, to) {
    from <- paste0(from, "-box")
    to <- paste0(to, "-box")
    grid.segments(grobX(from, 270), grobY(from, 270),
                  grobX(to, 90), grobY(to, 90),
                  arrow=arr, gp=gpar(fill="black"))
}

mpedge <- function(from, to) {
    from <- paste0(from, "-box")
    to <- paste0(to, "-box")
    fromx <- convertX(grobX(from, 270), "pt")
    fromy <- convertY(grobY(from, 270), "pt")
    tox <- convertX(grobX(to, 90), "pt")
    toy <- convertY(grobY(to, 90), "pt")
    p <- knot(fromx, fromy, dir.right=270) %+% knot(tox, toy, dir.left=270)
    metapost(p, "edge.mp")
    mpost("edge.mp")
    controls <- mptrace("edge.log")[[1]]
    pts <- BezierPoints(BezierGrob(controls$x, controls$y,
                                   default.units="pt"))
    grid.lines(pts$x, pts$y, default.units="in",
               arrow=arr, gp=gpar(fill="black"))
}

cedge <- function(from, to, curve=-1, fromext=NULL, toext=NULL) {
    from <- paste0(from, "-box")
    to <- paste0(to, "-box")
    fromx <- convertX(grobX(from, 270), "pt")
    fromy <- convertY(grobY(from, 270), "pt")
    tox <- convertX(grobX(to, 90), "pt")
    toy <- convertY(grobY(to, 90), "pt")
    if (!is.null(fromext)) {
        grid.segments(fromx, fromy, fromx, fromy - fromext)
        fromy <- fromy - fromext
    }
    arrow <- arr
    if (!is.null(toext)) {
        grid.segments(tox, toy + toext, tox, toy, arrow=arr,
                      gp=gpar(fill="black"))
        toy <- toy + toext
        arrow <- NULL 
    }
    grid.curve(fromx, fromy, tox, toy,
               inflect=TRUE, square=TRUE,
               curvature=curve,
               arrow=arrow, gp=gpar(fill="black"))    
}

node("knot()+knot()", 1, 2, "knot")
node('"mppath"', 2, 2, "mppath", box=TRUE)
edge("knot", "mppath")
node("metapost()", 3, 2, "metapost")
edge("mppath", "metapost")
node(".mp file", 4, 1, "mpfile", font="sans", box=TRUE)
cedge("metapost", "mpfile")
node("mpost()", 5, 2, "mpost")
cedge("mpfile", "mpost", curve=1)
node(".ps file", 6, 1, "psfile", font="sans", box=TRUE)
cedge("mpost", "psfile")
node(".log file", 7, 1, "logfile", font="sans", box=TRUE)
cedge("mpost", "logfile", fromext=unit(1.5, "cm"))
node("mptrace()", 8, 2, "mptrace")
cedge("logfile", "mptrace", curve=1)
node('"mpcontrols"', 9, 2, "mpcontrols", box=TRUE)
edge("mptrace", "mpcontrols")
node("grid.metapost()", 10, 2, "grid.metapost")
edge("mpcontrols", "grid.metapost")
node("rendered path", 12, 3, "rendered", box=TRUE, font="sans")
cedge("grid.metapost", "rendered", curve=1)
    
node("mpsolve()", 8, 3, "mpsolve")
cedge("mppath", "mpsolve", curve=1, toext=unit(7, "cm"))
cedge("mpsolve", "mpcontrols")

node("PostScriptTrace()", 6, 4, "pstrace")
node(".xml file", 7, 5, "xmlfile", box=TRUE, font="sans")
cedge("pstrace", "xmlfile", curve=1)
node("readPicture()", 8, 4, "readPicture")
cedge("xmlfile", "readPicture")
node('"picture"', 9, 4, "picture", box=TRUE)
edge("readPicture", "picture")
node("grid.picture()", 10, 4, "grid.picture")
edge("picture", "grid.picture")
cedge("grid.picture", "rendered")

x1 <- convertX(grobX("psfile-box", 180), "in")
x2 <- convertX(grobX("psfile-box", 180), "in") - unit(5, "mm")
x3 <- convertX(grobX("xmlfile-box", 90), "in")
x4 <- convertX(grobX("pstrace-box", 90), "in")
y1 <- convertY(grobY("psfile-box", 180), "in")
y2 <- unit(1, "npc") + unit(5, "mm")
y3 <- convertY(grobY("mpost-box", 270), "in")
y4 <- convertY(grobY("pstrace-box", 90), "in")
gap <- unit(2, "mm")
p <- knot(x1, y1) -
    knot(x2 + gap, y1) + dir(180) + dir(90) + knot(x2, y1 + gap) -
    knot(x2, y2 - gap) + dir(90) + dir(0) + knot(x2 + gap, y2) -
    knot(x3 - gap, y2) + dir(0) + dir(270) + knot(x3, y2 - gap) -
    knot(x3, y3)
grid.metapost(p)
grid.curve(x3, y3, x4, y4,
           square=TRUE, inflect=TRUE, curvature=-1,
           arrow=arr, gp=gpar(fill="black")) 
           
dev.off()
