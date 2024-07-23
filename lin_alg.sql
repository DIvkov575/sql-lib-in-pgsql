create or replace function dot(in x float[][], in y float[])
    returns float[]
    language plpgsql stable
as $$
declare
    output float[];
    i int;
    j int;
    aggregate float;
begin
    for i in 1..array_length(x, 1) loop
            aggregate = 0;
            for j in 1..array_length(x, 2) loop
                    aggregate := aggregate + x[i][j] * y[j];
                end loop;
            output := array_append(output, aggregate);
        end loop;

    return output;
end;
$$;

create or replace function t(in x float[][])
    returns float[][]
    language plpgsql stable
as $$
declare
    output float[][];

    i int;
    j int;

    i_len int; -- features in input
    j_len int; -- elems in input
begin

    i_len = array_length(x, 1);
    j_len = array_length(x, 2);
    output := array_fill(NULL::float, ARRAY[j_len, i_len]);

    for j in 1..j_len loop
            for i in 1..i_len loop
                    output[j][i] = x[i][j];
                end loop;
        end loop;

    return output;
end;
$$;





