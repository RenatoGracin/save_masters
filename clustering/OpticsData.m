classdef OpticsData < handle
    properties
        length = 0
        dataset = 0
        processed = 0
        reach_distances = 0
        core_distances = 0
        ordered_list = 0
        ordered_count = 0
        ordered_seeds = 0
        seed_count = 0
    end
    methods
        function obj = OpticsData(data)
            arguments
                data (:,:) {mustBeNumeric(data)}
            end
            
            obj.dataset = data;
            obj.length = length(data(:,1));
            obj.processed = ones(1,obj.length)*-1;
            obj.reach_distances = ones(1,obj.length)*-1;
            obj.core_distances = ones(1,obj.length)*-1;
            obj.ordered_list = [];
            obj.ordered_count = 0;
            obj.ordered_seeds = [];
            obj.seed_count = 0;
        end
    end
end

