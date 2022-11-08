function plotPrefs_launchIR(cb)

P.do_disagreement = cb.dis.Value;
P.do_percent_agreement = cb.peragree.Value;
P.do_percent_overlap = cb.peroverlap.Value;
P.do_IR_performance = cb.perf.Value;
P.visualize_annotations = cb.visann.Value;
P.do_subset = cb.ratersubset.Value;
interrater_module(P);
end