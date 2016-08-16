# -*- coding: utf-8 -*-
#BEGIN_HEADER
from doekbase.data_api.annotation.genome_annotation.api import GenomeAnnotationAPI as GenomeAnnotationAPI_local
from doekbase.data_api import cache
import logging
#END_HEADER


class TmpGnmAnnApi:
    '''
    Module Name:
    TmpGnmAnnApi

    Module Description:
    A KBase module: TmpGnmAnnApi
    '''

    ######## WARNING FOR GEVENT USERS #######
    # Since asynchronous IO can lead to methods - even the same method -
    # interrupting each other, you must be *very* careful when using global
    # state. A method could easily clobber the state set by another while
    # the latter method is running.
    #########################################
    VERSION = "0.0.1"
    GIT_URL = ""
    GIT_COMMIT_HASH = ""
    
    #BEGIN_CLASS_HEADER
    #END_CLASS_HEADER

    # config contains contents of config file in a hash or None if it couldn't
    # be found
    def __init__(self, config):
        #BEGIN_CONSTRUCTOR
        self.logger = logging.getLogger()
        log_handler = logging.StreamHandler()
        log_handler.setFormatter(logging.Formatter("%(asctime)s [%(levelname)s] %(message)s"))
        self.logger.addHandler(log_handler)

        self.services = {
            "workspace_service_url": config['workspace-url'],
            "shock_service_url": config['shock-url'],
            "handle_service_url": config['handle-service-url']
        }

        try:
            cache_dir = config['cache_dir']
        except KeyError:
            cache_dir = None

        try:
            redis_host = config['redis_host']
            redis_port = config['redis_port']
        except KeyError:
            redis_host = None
            redis_port = None

        if redis_host is not None and redis_port is not None:
            self.logger.info("Activating REDIS at host:{} port:{}".format(redis_host, redis_port))
            cache.ObjectCache.cache_class = cache.RedisCache
            cache.ObjectCache.cache_params = {'redis_host': redis_host, 'redis_port': redis_port}
        elif cache_dir is not None:
            self.logger.info("Activating File")
            cache.ObjectCache.cache_class = cache.DBMCache
            cache.ObjectCache.cache_params = {'path':cache_dir,'name':'data_api'}
        else:
            self.logger.info("Not activating REDIS")

        #END_CONSTRUCTOR
        pass
    

    def get_combined_data(self, ctx, params):
        """
        Retrieve any part of GenomeAnnotation. Please don't use this method in full mode (with all parts included) in cases
        of large eukaryotic datasets. It may lead to out-of-memory errors.
        :param params: instance of type "GetCombinedDataParams" (* Retrieve
           any part of GenomeAnnotation. * Any of exclude_genes,
           include_mrnas and exclude_cdss flags override values listed in
           include_features_by_type.) -> structure: parameter "ref" of type
           "ObjectReference", parameter "exclude_genes" of type "boolean" (A
           boolean - 0 for false, 1 for true. @range (0, 1)), parameter
           "include_mrnas" of type "boolean" (A boolean - 0 for false, 1 for
           true. @range (0, 1)), parameter "exclude_cdss" of type "boolean"
           (A boolean - 0 for false, 1 for true. @range (0, 1)), parameter
           "include_features_by_type" of list of String, parameter
           "exclude_protein_by_cds_id" of type "boolean" (A boolean - 0 for
           false, 1 for true. @range (0, 1)), parameter
           "include_mrna_ids_by_gene_id" of type "boolean" (A boolean - 0 for
           false, 1 for true. @range (0, 1)), parameter
           "exclude_cds_ids_by_gene_id" of type "boolean" (A boolean - 0 for
           false, 1 for true. @range (0, 1)), parameter
           "include_cds_id_by_mrna_id" of type "boolean" (A boolean - 0 for
           false, 1 for true. @range (0, 1)), parameter
           "include_exons_by_mrna_id" of type "boolean" (A boolean - 0 for
           false, 1 for true. @range (0, 1)), parameter
           "include_utr_by_utr_type_by_mrna_id" of type "boolean" (A boolean
           - 0 for false, 1 for true. @range (0, 1)), parameter
           "exclude_summary" of type "boolean" (A boolean - 0 for false, 1
           for true. @range (0, 1))
        :returns: instance of type "GenomeAnnotation_data" (gene_id is a
           feature id of a gene feature. mrna_id is a feature id of a mrna
           feature. cds_id is a feature id of a cds feature.) -> structure:
           parameter "gene_type" of String, parameter "mrna_type" of String,
           parameter "cds_type" of String, parameter "feature_types" of list
           of String, parameter "feature_by_id_by_type" of mapping from
           String to mapping from String to type "Feature_data" -> structure:
           parameter "feature_id" of String, parameter "feature_type" of
           String, parameter "feature_function" of String, parameter
           "feature_aliases" of mapping from String to list of String,
           parameter "feature_dna_sequence_length" of Long, parameter
           "feature_dna_sequence" of String, parameter "feature_md5" of
           String, parameter "feature_locations" of list of type "Region" ->
           structure: parameter "contig_id" of String, parameter "strand" of
           String, parameter "start" of Long, parameter "length" of Long,
           parameter "feature_publications" of list of String, parameter
           "feature_quality_warnings" of list of String, parameter
           "feature_quality_score" of list of String, parameter
           "feature_notes" of String, parameter "feature_inference" of
           String, parameter "protein_by_cds_id" of mapping from String to
           type "Protein_data" -> structure: parameter "protein_id" of
           String, parameter "protein_amino_acid_sequence" of String,
           parameter "protein_function" of String, parameter
           "protein_aliases" of list of String, parameter "protein_md5" of
           String, parameter "protein_domain_locations" of list of String,
           parameter "mrna_ids_by_gene_id" of mapping from String to list of
           String, parameter "cds_ids_by_gene_id" of mapping from String to
           list of String, parameter "cds_id_by_mrna_id" of mapping from
           String to String, parameter "exons_by_mrna_id" of mapping from
           String to list of type "Exon_data" -> structure: parameter
           "exon_location" of type "Region" -> structure: parameter
           "contig_id" of String, parameter "strand" of String, parameter
           "start" of Long, parameter "length" of Long, parameter
           "exon_dna_sequence" of String, parameter "exon_ordinal" of Long,
           parameter "utr_by_utr_type_by_mrna_id" of mapping from String to
           mapping from String to type "UTR_data" -> structure: parameter
           "utr_locations" of list of type "Region" -> structure: parameter
           "contig_id" of String, parameter "strand" of String, parameter
           "start" of Long, parameter "length" of Long, parameter
           "utr_dna_sequence" of String, parameter "summary" of type
           "Summary_data" -> structure: parameter "scientific_name" of
           String, parameter "taxonomy_id" of Long, parameter "kingdom" of
           String, parameter "scientific_lineage" of list of String,
           parameter "genetic_code" of Long, parameter "organism_aliases" of
           list of String, parameter "assembly_source" of String, parameter
           "assembly_source_id" of String, parameter "assembly_source_date"
           of String, parameter "gc_content" of Double, parameter "dna_size"
           of Long, parameter "num_contigs" of Long, parameter "contig_ids"
           of list of String, parameter "external_source" of String,
           parameter "external_source_date" of String, parameter "release" of
           String, parameter "original_source_filename" of String, parameter
           "feature_type_counts" of mapping from String to Long
        """
        # ctx is the context object
        # return variables are: returnVal
        #BEGIN get_combined_data
        exclude_genes = 'exclude_genes' in params and params['exclude_genes'] == 1
        include_mrnas = 'include_mrnas' in params and params['include_mrnas'] == 1
        exclude_cdss = 'exclude_cdss' in params and params['exclude_cdss'] == 1
        gene_type = 'gene'
        mrna_type = 'mRNA'
        cds_type = 'CDS'
        load_features_by_type = None
        if 'include_features_by_type' in params:
            load_features_by_type = set(params['include_features_by_type'])
        else:
            load_features_by_type = set([gene_type, cds_type])
        if exclude_genes and gene_type in load_features_by_type:
            load_features_by_type.remove(gene_type)
        if include_mrnas:
            load_features_by_type.add(mrna_type)
        if exclude_cdss and cds_type in load_features_by_type:
            load_features_by_type.remove(cds_type)
        load_protein_by_cds_id = not ('exclude_protein_by_cds_id' in params and params['exclude_protein_by_cds_id'] == 1)
        load_mrna_ids_by_gene_id = 'include_mrna_ids_by_gene_id' in params and params['include_mrna_ids_by_gene_id'] == 1
        load_cds_ids_by_gene_id = not ('exclude_cds_ids_by_gene_id' in params and params['exclude_cds_ids_by_gene_id'] == 1)
        load_cds_id_by_mrna_id = 'include_cds_id_by_mrna_id' in params and params['include_cds_id_by_mrna_id'] == 1
        load_exons_by_mrna_id = 'include_exons_by_mrna_id' in params and params['include_exons_by_mrna_id'] == 1
        load_utr_by_utr_type_by_mrna_id = 'include_utr_by_utr_type_by_mrna_id' in params and params['include_utr_by_utr_type_by_mrna_id'] == 1
        load_summary = not ('exclude_summary' in params and params['exclude_summary'] == 1)
        ga = GenomeAnnotationAPI_local(self.services, ctx['token'], params['ref'])
        genome_data = {'gene_type': gene_type, 'mrna_type': mrna_type, 'cds_type': cds_type}
        all_feature_types = ga.get_feature_types()
        genome_data['feature_types'] = all_feature_types
        feature_types_to_load = list(load_features_by_type)
        feature_ids_by_type = ga.get_feature_ids({"type_list": all_feature_types})['by_type']
        feature_ids = []
        for feature_type in feature_types_to_load:
            feature_ids.extend(feature_ids_by_type[feature_type])
        feature_map = None
        if len(feature_ids) > 0:
            feature_map = ga.get_features(feature_ids)
        else:
            feature_map = {}
        feature_by_id_by_type = {}
        for feature_type in feature_types_to_load:
            id_to_feature = {}
            for feature_id in feature_ids_by_type[feature_type]:
                id_to_feature[feature_id] = feature_map[feature_id]
            feature_by_id_by_type[feature_type] = id_to_feature
        genome_data['feature_by_id_by_type'] = feature_by_id_by_type
        if load_protein_by_cds_id:
            genome_data['protein_by_cds_id'] = ga.get_proteins()
        if load_mrna_ids_by_gene_id:
            genome_data['mrna_ids_by_gene_id'] = ga.get_mrna_by_gene(feature_ids_by_type[gene_type])
        if load_cds_ids_by_gene_id:
            genome_data['cds_ids_by_gene_id'] = ga.get_cds_by_gene(feature_ids_by_type[gene_type])
        if load_cds_id_by_mrna_id:
            genome_data['cds_id_by_mrna_id'] = ga.get_cds_by_mrna()
        if load_exons_by_mrna_id:
            genome_data['exons_by_mrna_id'] = ga.get_mrna_exons()
        if load_utr_by_utr_type_by_mrna_id:
            genome_data['utr_by_utr_type_by_mrna_id'] = ga.get_mrna_utrs()
        if load_summary:
            genome_data['summary'] = ga.get_summary()
        returnVal = genome_data
        #END get_combined_data

        # At some point might do deeper type checking...
        if not isinstance(returnVal, dict):
            raise ValueError('Method get_combined_data return value ' +
                             'returnVal is not type dict as required.')
        # return the results
        return [returnVal]

    def status(self, ctx):
        #BEGIN_STATUS
        returnVal = {'state': "OK", 'message': "", 'version': self.VERSION,
                     'git_url': self.GIT_URL, 'git_commit_hash': self.GIT_COMMIT_HASH}
        #END_STATUS
        return [returnVal]
