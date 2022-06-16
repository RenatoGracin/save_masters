function [outputArg1,outputArg2] = optics_calc_clusters(reach_dist,steep_perc,min_points)

    areas = init_steepness_areas(reach_dist,steep_perc,min_points);

    SetOfSteepDownAreas = [];
    SetOfClusters= [];
    index = 1;
    mib = 0;
    n = length(reach_dist);
    down_start_ind = 0;
    down_end_ind = 0;
    up_end_ind = 0;
    up_start_ind = 0;
    number_of_not_steep_points_in_a_row = 0;
    current_area = 0; % -1 = steep down, 0 = steep neutral, 1 = steep up
    area_data = [];
    while (index<=n)
%         mib = max([mib,reach_dist(index)]);
        curr_steepness = get_point_steepness(index,reach_dist,steep_perc);
        if curr_steepness == -1
            if current_area == -1
                if reach_dist(index) <= reach_dist(index+1)
                    area_data
                    index = index+1;
                else
                    down_end_ind = index;

                end
            elseif current_area == 0
                 down_start_ind = index;
            elseif current_area == 1

            end
            down_start_ind = index;
        end
%         down_start_ind, up_end_ind
%         max_clust_reach_dist = max(reach_dist(down_start_ind+1:up_end_ind+1));
        %% CHeck if points reach dist is steeper than clust start point
%         if max_clust_reach_dist <= (reach_dist(down_start_ind)*(1-steep_perc))
%         
%         end
         %% CHeck if points reach dist is steeper than clust end point
%         if max_clust_reach_dist <= (reach_dist(up_end_ind)*(1-steep_perc))
%         
%         end
        %% Maximum between values - mib - maximum between certain point and current index
        %% Steep down region mib - maximum between end point of steep down region and current index
        %% Global mib - maximum between end point of last steep (down or up) region and current index
    end
end

function areas = init_steepness_areas(reach_dist,steep_perc,min_points)
    areas = [];
    curr_area_data = [];
    current_area = 0;
    normal_points_count = 0;
    area_start_index = 0;
    area_end_index = 0;
    for index = 1:length(reach_dist)
        curr_steepness = get_point_steepness(index,reach_dist,steep_perc);
        if current_area == -1
            if reach_dist(index) <= reach_dist(index+1)
                area_data
                index = index+1;
            else
                down_end_ind = index;

            end
        elseif current_area == 0
             if curr_steepness == -1
             area_start_index = index;
        elseif current_area == 1

        end
        down_start_ind = index;
    end
end

function [is_valid] = check_area_condition(index,reach_dist,area_type,neutral_points_num,min_points)
    if area_type == -1
        if reach_dist(index) <= reach_dist(index+1) && neutral_points_num<min_points
            is_valid = 1;
        else
            is_valid = 0;
        end
    elseif area_type == 0
        if 
    elseif area_type == 1
        if reach_dist(index) >= reach_dist(index+1) && neutral_points_num<min_points
            is_valid = 1;
        else
            is_valid = 0;
        end
    end
end
% -1 = steep down, 0 = steep neutral, 1 = steep up
function [steepness] = get_point_steepness(curr_index, reach_dist,steep_perc)
    if is_steep_down_point(curr_index, reach_dist,steep_perc)
        steepness = -1;
    elseif is_steep_up_point(curr_index, reach_dist,steep_perc)
        steepness = 1;
    else
        steepness = 0;
    end
end

function [is_steep_down] = is_steep_down_point(curr_index, reach_dist,steep_perc)
    is_steep_down = reach_dist(curr_index)*(1-steep_perc) <= reach_dist(curr_index+1);
end

function [is_steep_up] = is_steep_up_point(curr_index, reach_dist,steep_perc)
    is_steep_up = reach_dist(curr_index) <= reach_dist(curr_index+1)*(1-steep_perc);
end
