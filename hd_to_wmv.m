clc
clear
tic

[ in_f , in_p ]     = uigetfile( '*.hd' )                                                               ;
input_file          = fullfile( in_p , in_f )                                                           ;
frame_info          = quick_ffd9_find( input_file )                                                     ;
[ p , f , e ]       = fileparts( input_file )                                                           ;
writerObj           = VideoWriter( [ pwd '\' f '.avi' ] )                                               ;
writerObj.FrameRate = 4                                                                                 ;
writerObj.Quality   = 100                                                                               ;
                      open( writerObj )
mapped_file         = memmapfile( input_file )                                                          ;
h_wait              = waitbar( 0 , 'Loading Video Frames' )                                             ;
total_frames        = numel( frame_info )                                                               ;

start_byte          = frame_info( 1 ).start                                                             ;
end_byte            = frame_info( 1 ).end                                                               ;
temp                = bin2im( mapped_file.Data( start_byte : end_byte ) )                               ;
queue_size          = 6                                                                                 ;
queue_dims          = [ size( temp ) queue_size ]                                                       ;
queue               = uint8( zeros( queue_dims ) )                                                      ;

% frames_to_proc      = 5 * queue_size                                                                	;
frames_to_proc      = 5%total_frames                                                                      ;

for i = 1 : min( frames_to_proc , total_frames )
    start_byte                      = frame_info( i ).start                                             ;
    end_byte                        = frame_info( i ).end                                               ;
    queue_spot                      = mod( i-1, queue_size ) + 1                                        ;
    queue( : , : , : , queue_spot )	= bin2im( mapped_file.Data( start_byte : end_byte ) )               ;
    progress                        = i / total_frames                                                  ;
    
	waitbar( progress , h_wait , sprintf( 'Frame %d of %d has been read.' , i , total_frames ) )
                                      
    if ~mod( i , queue_size ) || ( i == frames_to_proc )
        waitbar( progress , h_wait , sprintf( 'Writing %d frames' , queue_size ) )
        writeVideo( writerObj , queue( : , : , : , : ) )                                                ;
    end
end

elapsed             = toc  
time_per_frame      = toc / i                                                                       	;
fprintf( 'For queue size %d, time per frame was %f\n' , queue_size , time_per_frame )
close(writerObj);