FROM elasticsearch:7.17.2

RUN bash /usr/share/elasticsearch/bin/elasticsearch-plugin install analysis-icu 
RUN bash /usr/share/elasticsearch/bin/elasticsearch-plugin install analysis-kuromoji 
RUN bash /usr/share/elasticsearch/bin/elasticsearch-plugin install analysis-smartcn
RUN bash /usr/share/elasticsearch/bin/elasticsearch-plugin install analysis-stempel
    
EXPOSE 9200
EXPOSE 9300