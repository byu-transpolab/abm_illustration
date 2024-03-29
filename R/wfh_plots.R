plot_wfh_tlfd_diff <- function(combined_trip_diff, distances) {
	combined_trip_diff %>%
		mutate(missing_trips = -diff) %>%
		filter(missing_trips > 0, purpose == "hbw") %>%
		mutate(
			model = pretty_model(model),
			mode = pretty_mode(mode)
		) %>%
		left_join(distances, join_by(origin, destination)) %>%
		ggplot(aes(color = model, x = distance, weight = missing_trips)) +
		facet_wrap(~mode, scales = "free", ncol = 1) +
		facetted_pos_scales(
			x = list(
				mode == "Auto" ~ scale_x_continuous(limits = c(0,30)),
				mode == "Non-motorized" ~ scale_x_continuous(limits = c(0,10)),
				mode == "Transit" ~ scale_x_continuous(limits = c(0,30))
			)
		) +
		geom_density() +
		# theme(legend.position = "bottom") +
		labs(x = "Trip Distance (miles)", y = "Kernel density", color = "Model")
}

plot_wfh_by_tlfd_diff_comp <- function(combined_trip_diff, which_model, distances) {
	trips <- combined_trip_diff %>%
		mutate(missing_trips = -diff) %>%
		filter(purpose == "hbw", model == which_model) %>%
		left_join(distances, join_by(origin, destination)) %>%
		select(mode, by, missing_trips, distance) %>%
		pivot_longer(c(by, missing_trips), names_to = "scenario", values_to = "trips") %>%
		filter(trips > 0)

	scenario_labels <- c(
		by = "Baseline Scenario",
		missing_trips = "\"Missing\" trips in\nIncreased WFH Scenario")

	trips %>%
		mutate(mode = pretty_mode(mode)) %>%
		ggplot(aes(x = distance, color = scenario, lty = scenario, weight = trips)) +
		facet_wrap(~mode, scales = "free", ncol = 1) +
		facetted_pos_scales(x = list(
			mode == "Auto" ~ scale_x_continuous(limits = c(NA,30)),
			mode == "Non-motorized" ~ scale_x_continuous(limits = c(NA,10)),
			mode == "Transit" ~ scale_x_continuous(limits = c(NA,20)))) +
		geom_density() +
		scale_color_manual(
			values = c(by = "grey50", missing_trips = "navy"),
			labels = scenario_labels) +
		scale_linetype_manual(
			values = c(by = "dashed", missing_trips = "solid"),
			labels = scenario_labels) +
		labs(
			x = "Trip Distance (miles)", y = "Kernel density",
			color = "Scenario", lty = "Scenario")
}
