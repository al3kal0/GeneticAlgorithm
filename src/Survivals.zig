const GeneticAlg = @import("GeneticAlg.zig").GeneticAlg;

pub fn NexGenSurvival(comptime T: type, algorithm: *GeneticAlg(T)) void
{
    var population = algorithm.population;
    var matingpool = algorithm.matingpool;

    var i: usize = 0;
    while(i < algorithm.matingpool_count) : (i += 1)
    {
        population[i] = matingpool[i];
        algorithm.population_count += 1;
    }
}
