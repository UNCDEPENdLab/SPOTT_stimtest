function Condition = SetupFactorial(trials, factorXvals,factorYvals, factorZvals)
%%  create an X by Y by Z factorial design, which crosses all values of
%%  condition 1 and condition 2 and condition 3 such that there are a total of "trials"


%trials is the number of trials
%factorXvals is the list of values that are crossed with factorYvals

%at the end of this function there will be X by Y by Z by N trials, where
% X is the number of condition 1 levels
% Y is the number of condition 2 levels
% Z is the number of condition 3 levels
% N is the number of trials per combination of conditions

%for example, if there are 36 trials total, factor X has 3 levels,
%factor Y has 3 levels, and Z has one level then there are 9 combinations of X and Y,
%and 4 trials per combination   (3 x 3 x 4 = 36)


%this function generates the table of all possible condition combinations
%and then returns the list of those trials in randomly shuffled order


Numper(1) = ceil(trials/length(factorXvals));
Numper(2) = ceil(Numper(1)/length(factorYvals));
Numper(3) = ceil(Numper(2)/length(factorZvals));

if(mod(trials, (length(factorXvals) * length(factorYvals)* length(factorZvals)))>0)
    error('Error, number of trials not an even multiple of the total combination of all conditions in SetupFactorial')
end


%%
%reset Condition
Condition = 0;

%populates the array Condition
for(s = 1:length(factorXvals))
    sstart = (s-1)*Numper(1);
    sstop = s*Numper(1);
    Condition(1,sstart+1:sstop) = factorXvals(s);
    for(s2 = 1:length(factorYvals))
        s2start = sstart + (s2-1)*Numper(2);
        s2stop = sstart + s2 *Numper(2);
        Condition(2,s2start+1:s2stop) =factorYvals(s2);

        for(s3 = 1:length(factorZvals))
            s3start = s2start + (s3-1)*Numper(3);
            s3stop = s2start + s3 *Numper(3);
            Condition(3,s3start+1:s3stop) =factorZvals(s3);

        end
    end
end

Condition = shuffle(Condition,2);   %now shuffle the order of the trials

end

%The Condition array contains ALL the possible combinations of the two
%factors
%Each column represents one combination
%Each column has two of the same, grouped together
