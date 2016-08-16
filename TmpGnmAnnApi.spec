/*
A KBase module: TmpGnmAnnApi
*/

module TmpGnmAnnApi {
    typedef string ObjectReference;

    /* A boolean - 0 for false, 1 for true.
       @range (0, 1)
    */
    typedef int boolean;

    typedef structure {
        /** The identifier for the contig to which this region corresponds. */
        string contig_id;
        /** Either a "+" or a "-", for the strand on which the region is located. */
        string strand;
        /** Starting position for this region. */
        int start;
        /** Distance from the start position that bounds the end of the region. */
        int length;
    }  Region;

    /**
     * Filters passed to :meth:`get_feature_ids`
     * @optional type_list region_list function_list alias_list
     */
    typedef structure {
        /**
         * List of Feature type strings.
         */
        list<string> type_list;
        /**
         * List of region specs.
         * For example::
         *     [{"contig_id": str, "strand": "+"|"-",
         *       "start": int, "length": int},...]
         *
         * The Feature sequence begin and end are calculated as follows:
         *   - [start, start) for "+" strand
         *   - (start - length, start] for "-" strand
         */
        list<Region> region_list;
        /**
         * List of function strings.
         */
        list<string> function_list;
        /**
         *  List of alias strings.
         */
        list<string> alias_list;
    }  Feature_id_filters;

    /* @optional by_type by_region by_function by_alias */
    typedef structure {
        /** Mapping of Feature type string to a list of Feature IDs */
        mapping<string, list<string>> by_type;
        /**
         * Mapping of contig ID, strand "+" or "-", and range "start--end" to
         * a list of Feature IDs. For example::
         *    {'contig1': {'+': {'123--456': ['feature1', 'feature2'] }}}
         */
        mapping<string, mapping<string, mapping<string, list<string>>>> by_region;
        /** Mapping of function string to a list of Feature IDs */
        mapping<string, list<string>> by_function;
        /** Mapping of alias string to a list of Feature IDs */
        mapping<string, list<string>> by_alias;
    }  Feature_id_mapping;

    typedef structure {
        /** Identifier for this feature */
        string feature_id;
        /** The Feature type e.g., "mRNA", "CDS", "gene", ... */
        string feature_type;
        /** The functional annotation description */
        string feature_function;
        /** Dictionary of Alias string to List of source string identifiers */
        mapping<string, list<string>> feature_aliases;
        /** Integer representing the length of the DNA sequence for convenience */
        int feature_dna_sequence_length;
        /** String containing the DNA sequence of the Feature */
        string feature_dna_sequence;
        /** String containing the MD5 of the sequence, calculated from the uppercase string */
        string feature_md5;
        /**
         * List of dictionaries::
         *     { "contig_id": str,
         *       "start": int,
         *       "strand": str,
         *       "length": int  }
         *
         * List of Feature regions, where the Feature bounds are
         * calculated as follows:
         *
         * - For "+" strand, [start, start + length)
         * - For "-" strand, (start - length, start]
        */
        list<Region> feature_locations;
        /**
         * List of any known publications related to this Feature
         */
        list<string> feature_publications;
        /**
         * List of strings indicating known data quality issues.
         * Note: not used for Genome type, but is used for
         * GenomeAnnotation
         */
        list<string> feature_quality_warnings;
        /**
         * Quality value with unknown algorithm for Genomes,
         * not calculated yet for GenomeAnnotations.
         */
        list<string> feature_quality_score;
        /** Notes recorded about this Feature */
        string feature_notes;
        /** Inference information */
        string feature_inference;
    }  Feature_data;

    typedef structure {
        /** Protein identifier, which is feature ID plus ".protein" */
        string protein_id;
        /** Amino acid sequence for this protein */
        string protein_amino_acid_sequence;
        /** Function of protein */
        string protein_function;
        /** List of aliases for the protein */
        list<string> protein_aliases;
        /** MD5 hash of the protein translation (uppercase) */
        string protein_md5;
        list<string> protein_domain_locations;
    }  Protein_data;

    typedef structure {
        /** Location of the exon in the contig. */
        Region exon_location;
        /** DNA Sequence string. */
        string exon_dna_sequence;
        /** The position of the exon, ordered 5' to 3'. */
        int exon_ordinal;
    }  Exon_data;

    typedef structure {
        /** Locations of this UTR */
        list<Region> utr_locations;
        /** DNA sequence string for this UTR */
        string utr_dna_sequence;
    }  UTR_data;

    typedef structure {
        /** Scientific name of the organism. */
        string scientific_name;
        /** NCBI taxonomic id of the organism. */
        int taxonomy_id;
        /** Taxonomic kingdom of the organism. */
        string kingdom;
        /** Scientific lineage of the organism. */
        list<string> scientific_lineage;
        /** Scientific name of the organism. */
        int genetic_code;
        /** Aliases for the organism associated with this GenomeAnnotation. */
        list<string> organism_aliases;
        /** Source organization for the Assembly. */
        string assembly_source;
        /** Identifier for the Assembly used by the source organization. */
        string assembly_source_id;
        /** Date of origin the source indicates for the Assembly. */
        string assembly_source_date;
        /** GC content for the entire Assembly. */
        float gc_content;
        /** Total DNA size for the Assembly. */
        int dna_size;
        /** Number of contigs in the Assembly. */
        int num_contigs;
        /** Contig identifier strings for the Assembly. */
        list<string> contig_ids;
        /** Name of the external source. */
        string external_source;
        /** Date of origin the external source indicates for this GenomeAnnotation. */
        string external_source_date;
        /** Release version for this GenomeAnnotation data. */
        string release;
        /** Name of the file used to generate this GenomeAnnotation. */
        string original_source_filename;
        /** Number of features of each type. */
        mapping<string, int> feature_type_counts;
    } Summary_data;

    /*
        gene_id is a feature id of a gene feature.
        mrna_id is a feature id of a mrna feature.
        cds_id is a feature id of a cds feature.
    */
    typedef structure {
        string gene_type;
        string mrna_type;
        string cds_type;
        list<string> feature_types;
        mapping<string, mapping<string, Feature_data>> feature_by_id_by_type;
        mapping<string, Protein_data> protein_by_cds_id;
        mapping<string, list<string>> mrna_ids_by_gene_id;
        mapping<string, list<string>> cds_ids_by_gene_id;
        mapping<string, string> cds_id_by_mrna_id;
        mapping<string, list<Exon_data>> exons_by_mrna_id;
        mapping<string, mapping<string, UTR_data>> utr_by_utr_type_by_mrna_id;
        Summary_data summary;
    } GenomeAnnotation_data;

    /*
     * Retrieve any part of GenomeAnnotation.
     * Any of exclude_genes, include_mrnas and exclude_cdss flags override values listed in include_features_by_type.
     */
    typedef structure {
        ObjectReference ref;
        boolean exclude_genes;
        boolean include_mrnas;
        boolean exclude_cdss;
        list<string> include_features_by_type;
        boolean exclude_protein_by_cds_id;
        boolean include_mrna_ids_by_gene_id;
        boolean exclude_cds_ids_by_gene_id;
        boolean include_cds_id_by_mrna_id;
        boolean include_exons_by_mrna_id;
        boolean include_utr_by_utr_type_by_mrna_id;
        boolean exclude_summary;
    } GetCombinedDataParams;

    /*
     * Retrieve any part of GenomeAnnotation. Please don't use this method in full mode (with all parts included) in cases
     * of large eukaryotic datasets. It may lead to out-of-memory errors.
     */
    funcdef get_combined_data(GetCombinedDataParams params) returns (GenomeAnnotation_data) authentication required;

};
