function string get_time();
    int file_pointer;
    //Stores time and date to file sys_time
    void'($system("date +%X--%x > system_time"));
    //Open the file sys_time with read access
    file_pointer = $fopen("system_time","r");
    //assin the value from file to variable
    void'($fscanf(file_pointer,"%s",get_time));
    //close the file
    $fclose(file_pointer);
    void'($system("rm system_time"));
endfunction


function string split_using_delimiter_fn(input int offset, string str,string del,output int cnt);
  for (int i = offset; i < str.len(); i=i+1) 
    if (str.getc(i) == del) begin
       cnt = i;
       return str.substr(offset,i-1);
     end
endfunction

function automatic string split_str(output string str[$]);
 string str_time;
 int p_offset_in = 0;
 int p_offset_out = 0;
 int count = 0;
 
  str_time = get_time();
  $display("   STRING = %s",str_time);
  for(int j=0; j<3; j = j+1) begin
     str[j] = split_using_delimiter_fn(p_offset_in,str_time,":",p_offset_out);
       if(p_offset_in >= p_offset_out) 
         str[j] = str_time.substr(p_offset_in,str_time.len()-1);
       else 
          p_offset_in = p_offset_out+1;
       $display("   Splitted String %0d = %s",j,str[j]);
  end
endfunction

function automatic void calculate_diff(input string req_i[$], input string rsp_i[$], input string func);
    int fd;
    int hr, min, sec;
    if((rsp_i[1].atoi()-req_i[1].atoi())< 0) begin //min
        if((rsp_i[2].atoi()-req_i[2].atoi())< 0) begin //sec
           hr  = ( rsp_i[0].atoi() -1) - req_i[0].atoi();
           min = (rsp_i[1].atoi() + 'd60 - 1) - req_i[1].atoi() ; 
           sec = (rsp_i[2].atoi() + 'd60) - req_i[2].atoi();
        end
    end else if((rsp_i[1].atoi()-req_i[1].atoi())> 0) begin //min
        if((rsp_i[2].atoi()-req_i[2].atoi())< 0) begin //sec
             hr  =  rsp_i[0].atoi() - req_i[0].atoi();
             min = (rsp_i[1].atoi() - 1) - req_i[1].atoi() ; 
             sec = (rsp_i[2].atoi() + 'd60) - req_i[2].atoi();
        end
    end else begin
            hr  = rsp_i[0].atoi()-req_i[0].atoi();
            min = rsp_i[1].atoi()-req_i[1].atoi() ; 
            sec = rsp_i[2].atoi()-req_i[2].atoi();
    end
                      
    $display("cumulative time is %0d:%0d:%0d",hr,min,sec);
    fd = $fopen("response_data.txt", "a");
    $fdisplay (fd, "Time taken for %s completion %0d:%0d:%0d",func,hr,min,sec);
    $fclose(fd);
endfunction

`ifndef AVY_MEASURE
string req_g[$];
string rsp_g[$];
`endif

function avy_measure_start(input string pkt_header);
`ifdef AVY_MEASURE
    void'(avy_wallclock_diff(pkt_header, 1));
`else
    void'(split_str(req_g));
`endif
endfunction

function avy_measure_end(input string pkt_header);
`ifdef AVY_MEASURE
    void'(avy_wallclock_diff(pkt_header, 0));
`else
    void'(split_str(rsp_g));
    void'(calculate_diff(req_g, rsp_g, pkt_header));
`endif
endfunction

/* mb: shows how to import DPI into SystemVerilog */
import "DPI-C" function void avy_wallclock_diff(input string key, input byte init);



























