require 'spec_helper'

describe Arachni::Report::Base do
    before( :all ) do
        opts = Arachni::Options.instance
        opts.dir['reports'] = fixtures_path + 'reports/base_spec'

        @framework = Arachni::Framework.new( Arachni::Options.instance )
        @reports   = @framework.reports
    end

    describe '#auditstore' do
        it 'returns the provided auditstore' do
            auditstore = @framework.auditstore
            @reports.run_one( :with_outfile, auditstore ).auditstore.
                should == auditstore
        end
    end

    describe '#outfile' do
        it 'returns the outfile in options' do
            outfile = 'blahfile'
            @reports.run_one( :with_outfile, @framework.auditstore,
                              'outfile' => outfile
            ).outfile.should == outfile
        end

        context 'when a directory is provided as an outfile option' do
            it 'returns the path of default outfile filename under that directory' do
                @reports.run_one( :with_outfile, @framework.auditstore,
                                  'outfile' => '.'
                ).outfile.start_with?( File.expand_path( "." ) ).should be_true
            end
        end
    end

    describe '#format_plugin_results' do
        it 'runs the formatters of appropriate plugin' do
            store = @framework.auditstore
            store.plugins["foobar"] = { :results => 'Blah!' }

            @reports.run_one( 'with_formatters', store )
            IO.read( 'with_formatters' ).should == { 'foobar' => 'Blah!' }.to_s
            File.delete( 'with_formatters' )
        end
    end

    describe '.has_outfile?' do
        context 'when the report has an outfile option' do
            it 'returns true' do
                @reports[:with_outfile].has_outfile?.should be_true
            end
        end
        context 'when the report does not have an outfile option' do
            it 'returns false' do
                @reports[:without_outfile].has_outfile?.should be_false
            end
        end
    end

end
